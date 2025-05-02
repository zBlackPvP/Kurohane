export const siteConfig = {
  name: "OneBlacki Portfolio",
  description: "Portfolio pessoal mostrando projetos e habilidades",
  url: process.env.NEXT_PUBLIC_SITE_URL || "http://localhost:3000",
  ogImage: "/images/og-image.jpg",
  links: {
    github: "https://github.com/oneblacki",
    linkedin: "https://linkedin.com/in/oneblacki",
    twitter: "https://twitter.com/oneblacki",
  },
  author: {
    name: "Seu Nome",
    email: "email@example.com",
    avatar: "/images/avatar.jpg",
    bio: "Desenvolvedor Full Stack apaixonado por criar experiências web incríveis",
  },
  nav: [
    {
      title: "Home",
      href: "/",
    },
    {
      title: "Projetos",
      href: "/#projects",
    },
    {
      title: "Habilidades",
      href: "/#skills",
    },
    {
      title: "Experiência",
      href: "/#experience",
    },
    {
      title: "Contato",
      href: "/#contact",
    },
  ],
};

export type SiteConfig = typeof siteConfig;