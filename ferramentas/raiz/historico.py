#!/usr/bin/env python3
"""Reconstrói o histórico de todos os projetos a partir do próprio repositório.

Fontes, todas locais:
  - git log de todas as ramificações (commits, PRs, arquivos tocados);
  - supabase/migrations/ (a vida do Castelo desde 11/08, antes do repositório existir).

Cada evento é atribuído a um projeto pelo caminho dos arquivos que tocou.
Gera raiz/historico.html com os dados embutidos (abre até sem servidor).

Uso: python3 ferramentas/raiz/historico.py
"""
import json
import re
import subprocess
from collections import Counter
from datetime import datetime
from pathlib import Path

RAIZ = Path(__file__).resolve().parents[2]
MODELO = Path(__file__).with_name("historico.modelo.html")
SAIDA = RAIZ / "raiz" / "historico.html"

# Ordem importa: o primeiro prefixo que casar decide o projeto do arquivo.
PROJETOS = [
    ("raiz", "Raiz dos Nós", ["raiz.html", "raiz/", "ferramentas/raiz/"]),
    ("lab", "Super Evo Lab", ["superevolab/", ".github/workflows/blog.yml"]),
    ("sonar", "SONAR", ["sonar/", "investigar.html", "blog/radar.js", "blog/investigacoes/",
                        "docs/SONAR", "docs/projetos-sonar/"]),
    ("castelo", "Castelo", ["supabase/"]),
    ("grok", "Captura do Grok", ["docs/historico/", "captura-grok/"]),
    ("comercial", "Comercial e blog", ["blog/", "guia-p0.html", "ferramentas/blog/", "divulgacao/",
                                       "docs/KIT-DIVULGACAO", "docs/AGENTE-MARKET",
                                       "docs/MANUAL-COMERCIAL", "docs/ROTEIROS-CURSO"]),
    ("organismo", "Organismo", [".claude/", "CLAUDE.md", "README.md", "docs/", "LICENSE", ".gitignore"]),
    ("espelho", "Espelho", [""]),  # o resto da raiz: index, núcleos, porta, evo.json, PWA, Vercel
]
NOMES = {pid: nome for pid, nome, _ in PROJETOS}

# Hellwolf: nada que pareça segredo entra no histórico.
SEGREDO = re.compile(r"(sb_secret_\w+|service_role\s*[:=]\s*\S+|eyJ[\w-]{20,}|ghp_\w{20,}|sk-[\w-]{20,})")


def git(*args):
    return subprocess.run(["git", *args], cwd=RAIZ, capture_output=True, text=True, check=True).stdout


def projeto_do_arquivo(caminho):
    for pid, _, prefixos in PROJETOS:
        if any(caminho.startswith(p) for p in prefixos):
            return pid
    return "espelho"


def limpo(texto):
    return SEGREDO.sub("[omitido]", texto)


def ramos_por_commit():
    mapa = {}
    for ref in git("for-each-ref", "--format=%(refname:short)", "refs/remotes/origin").split():
        if ref.endswith("/HEAD"):
            continue
        nome = ref.removeprefix("origin/")
        for sha in git("rev-list", ref).split():
            mapa.setdefault(sha, []).append(nome)
    return mapa


def eventos_git():
    ramos = ramos_por_commit()
    bruto = git("log", "--all", "--reverse", "--name-only", "--date=iso-strict",
                "--format=\x1e%H\x1f%P\x1f%ad\x1f%an\x1f%s")
    eventos = []
    for bloco in bruto.split("\x1e")[1:]:
        cabeca, _, resto = bloco.partition("\n")
        sha, pais, data, autor, assunto = cabeca.split("\x1f")
        arquivos = [a for a in resto.splitlines() if a.strip()]
        pr = re.search(r"(?:Merge pull request #|\(#)(\d+)", assunto)
        fusao = len(pais.split()) > 1
        if fusao:
            # O git log não lista arquivos de merge: conta o que entrou em relação ao primeiro pai.
            arquivos = git("diff", "--name-only", pais.split()[0], sha).split()
        contagem = Counter(projeto_do_arquivo(a) for a in arquivos)
        eventos.append({
            "quando": data[:16].replace("T", " "),
            "tipo": "pr" if pr else ("fusao" if fusao else "commit"),
            "titulo": limpo(assunto),
            "autor": "Plasma (Claude)" if autor == "Claude" else autor,
            "ref": sha[:7],
            "pr": int(pr.group(1)) if pr else None,
            "projetos": [p for p, _ in contagem.most_common()] or ["organismo"],
            "arquivos": len(arquivos),
            "ramos": sorted(ramos.get(sha, [])),
        })
    return eventos


def eventos_migracoes():
    eventos = []
    for arq in sorted((RAIZ / "supabase" / "migrations").glob("*.sql")):
        versao, _, nome = arq.stem.partition("_")
        try:
            quando = datetime.strptime(versao, "%Y%m%d%H%M%S")
        except ValueError:
            continue
        nota = []
        for linha in arq.read_text(encoding="utf-8", errors="replace").splitlines()[:12]:
            linha = linha.strip()
            if not linha.startswith("--"):
                if nota:
                    break
                continue
            linha = linha.lstrip("- ").strip()
            if not linha or linha.startswith(("Migração ", "Exportada do Castelo")):
                continue
            nota.append(linha)
        eventos.append({
            "quando": quando.strftime("%Y-%m-%d %H:%M"),
            "tipo": "migracao",
            "titulo": nome.replace("_", " "),
            "nota": limpo(" ".join(nota))[:320],
            "ref": versao,
            "projetos": ["castelo"],
        })
    return eventos


def main():
    eventos = sorted(eventos_git() + eventos_migracoes(), key=lambda e: e["quando"])
    inicio = {}
    for e in eventos:
        for p in e["projetos"]:
            inicio.setdefault(p, e["quando"][:10])
    dados = {
        "gerado": datetime.now().strftime("%Y-%m-%d %H:%M"),
        "projetos": sorted(({"id": pid, "nome": nome, "inicio": inicio[pid]} for pid, nome, _ in PROJETOS
                            if pid in inicio), key=lambda p: p["inicio"]),
        "eventos": eventos,
    }
    blob = json.dumps(dados, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/")
    SAIDA.write_text(MODELO.read_text(encoding="utf-8").replace("/*DADOS*/null", blob), encoding="utf-8")
    print(f"{SAIDA.relative_to(RAIZ)}: {len(eventos)} eventos, {len(dados['projetos'])} projetos")


if __name__ == "__main__":
    main()
