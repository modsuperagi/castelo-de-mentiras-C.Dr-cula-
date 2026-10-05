import type { MetadataRoute } from "next";
import { listarPosts } from "@/lib/posts";
import { site } from "@/lib/site";

export default function sitemap(): MetadataRoute.Sitemap {
  const posts = listarPosts().map((p) => ({
    url: `${site.url}/posts/${p.slug}`,
    lastModified: p.data,
  }));
  return [
    { url: site.url, lastModified: posts[0]?.lastModified },
    { url: `${site.url}/sobre` },
    { url: `${site.url}/newsletter` },
    ...posts,
  ];
}
