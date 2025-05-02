"use client";

import { useState, useEffect } from "react";
import Image from "next/image";
import { motion } from "framer-motion";
import { siteConfig } from "@/config/site";
import { Button } from "@/components/ui/Button";
import { ArrowDown, Github, Linkedin } from "lucide-react";
import Link from "next/link";

export function HeroSection() {
  const [isVisible, setIsVisible] = useState(false);

  useEffect(() => {
    setIsVisible(true);
  }, []);

  return (
    <section className="relative pt-32 pb-20 md:pt-40 md:pb-32">
      <div className="absolute inset-0 z-0 bg-grid-pattern opacity-5"></div>
      <div className="container mx-auto px-4">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-center">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={isVisible ? { opacity: 1, y: 0 } : {}}
            transition={{ duration: 0.6 }}
          >
            <span className="inline-block px-3 py-1 text-sm font-medium bg-primary/10 text-primary rounded-full mb-4">
              Desenvolvedor Full Stack
            </span>
            <h1 className="text-4xl md:text-5xl lg:text-6xl font-bold mb-6">
              Transformando ideias em{" "}
              <span className="bg-gradient-to-r from-purple-600 via-blue-500 to-cyan-400 text-transparent bg-clip-text">
                experiências digitais
              </span>
            </h1>
            <p className="text-xl text-muted-foreground mb-8 max-w-lg">
              Criando soluções web inovadoras com foco em experiência do usuário e performance.
            </p>
            <div className="flex flex-wrap gap-4">
              <Button size="lg" asChild>
                <Link href="/#contact">Entre em contato</Link>
              </Button>
              <Button size="lg" variant="outline" asChild>
                <Link href="/#projects">Ver projetos</Link>
              </Button>
            </div>
            <div className="flex items-center gap-4 mt-8">
              <Link
                href={siteConfig.links.github}
                target="_blank"
                rel="noopener noreferrer"
                className="text-muted-foreground hover:text-primary transition-colors"
              >
                <Github className="h-6 w-6" />
                <span className="sr-only">GitHub</span>
              </Link>
              <Link
                href={siteConfig.links.linkedin}
                target="_blank"
                rel="noopener noreferrer"
                className="text-muted-foreground hover:text-primary transition-colors"
              >
                <Linkedin className="h-6 w-6" />
                <span className="sr-only">LinkedIn</span>
              </Link>
            </div>
          </motion.div>
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={isVisible ? { opacity: 1, scale: 1 } : {}}
            transition={{ duration: 0.6, delay: 0.2 }}
            className="relative hidden lg:block"
          >
            <div className="rounded-lg bg-gradient-to-r from-purple-600 via-blue-500 to-cyan-400 p-1 shadow-xl">
              <div className="aspect-square relative overflow-hidden bg-background rounded-md">
                <Image
                  src={siteConfig.author.avatar}
                  alt={siteConfig.author.name}
                  fill
                  className="object-cover"
                  priority
                />
              </div>
            </div>
            <div className="absolute -bottom-6 -right-6 bg-background rounded-full p-3 shadow-lg">
              <div className="bg-gradient-to-r from-purple-600 via-blue-500 to-cyan-400 rounded-full p-1">
                <div className="bg-background rounded-full p-2">
                  <code className="text-sm font-mono">{"<code />"}</code>
                </div>
              </div>
            </div>
          </motion.div>
        </div>
        <div className="absolute bottom-10 left-1/2 transform -translate-x-1/2 hidden md:block">
          <Button
            variant="ghost"
            size="icon"
            className="animate-bounce"
            aria-label="Scroll down"
            asChild
          >
            <a href="#about">
              <ArrowDown className="h-6 w-6" />
            </a>
          </Button>
        </div>
      </div>
    </section>
  );
}