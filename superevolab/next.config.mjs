/** @type {import('next').NextConfig} */
const nextConfig = {
  // Gera um site estático em out/: roda em qualquer hospedagem gratuita
  // (Cloudflare Pages, Netlify, GitHub Pages), sem servidor.
  output: "export",
  trailingSlash: true,
  poweredByHeader: false,
};

export default nextConfig;
