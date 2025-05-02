"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import { useInView } from "framer-motion";
import { useRef } from "react";
import Image from "next/image";
import Link from "next/link";
import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/Button";
import { ExternalLink, Github } from "lucide-react";

interface Project {
  id: string;
  title: string;
  description: string;
  image: string;
  tags: { id: string; name: string }[];
  demoUrl?: string;
  repoUrl?: string;
}

interface ProjectsData {
  projects: Project[];
}

interface ProjectCardProps {
  project: Project;
  index: number;
}

function ProjectCard({ project, index }: ProjectCardProps) {
  const isEven = index % 2 === 0;
  
  return (
    <motion.div
      initial={{ opacity: 0, y: 20 }}
      animate={{ opacity: 1, y: 0 }}
      transition={{ duration: 0.6, delay: index * 0.1 }}
      className={cn(
        "grid grid-cols-1 md:grid-cols-2 gap-8 items-center",
        isEven ? "" : "md:flex-row-reverse"
      )}
    >
      <div className={cn(isEven ? "md:order-1" : "md:order-2")}>
        <div className="relative overflow-hidden rounded-lg aspect-video bg-muted">
          <Image
            src={project.image || "/images/placeholder.jpg"}
            alt={project.title}
            fill
            className="object-cover transition-transform hover:scale-105 duration-300"
          />
        </div>
      </div>
      <div className={cn(isEven ? "md:order-2" : "md:order-1")}>
        <h3 className="text-2xl font-bold mb-3">{project.title}</h3>
        <p className="text-muted-foreground mb-4">{project.description}</p>
        <div className="flex flex-wrap gap-2 mb-6">
          {project.tags.map((tag) => (
            <span
              key={tag.id}
              className="text-xs font-medium px-2.5 py-0.5 rounded-full bg-primary/10 text-primary"
            >
              {tag.name}
            </span>
          ))}
        </div>
        <div className="flex flex-wrap gap-4">
          {project.demoUrl && (
            <Button size="sm" asChild>
              <a
                href={project.demoUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-2"
              >
                <ExternalLink size={16} />
                Ver demo
              </a>
            </Button>
          )}
          {project.repoUrl && (
            <Button size="sm" variant="outline" asChild>
              <a
                href={project.repoUrl}
                target="_blank"
                rel="noopener noreferrer"
                className="flex items-center gap-2"
              >
                <Github size={16} />
                Ver código
              </a>
            </Button>
          )}
        </div>
      </div>
    </motion.div>
  );
}

// Dados de exemplo para visualização
const SAMPLE_PROJECTS: Project[] = [
  {
    id: "1",
    title: "E-commerce Platform",
    description:
      "Plataforma de comércio eletrônico completa com carrinho de compras, pagamentos e painel de administração.",
    image: "/images/placeholder.jpg",
    tags: [
      { id: "1", name: "React" },
      { id: "2", name: "Node.js" },
      { id: "3", name: "PostgreSQL" },
    ],
    demoUrl: "https://example.com",
    repoUrl: "https://github.com/oneblacki/ecommerce",
  },
  {
    id: "2",
    title: "CRM System",
    description:
      "Sistema de gerenciamento de relacionamento com o cliente com recursos de análise e relatórios.",
    image: "/images/placeholder.jpg",
    tags: [
      { id: "4", name: "Next.js" },
      { id: "5", name: "Prisma" },
      { id: "6", name: "TypeScript" },
    ],
    demoUrl: "https://example.com",
    repoUrl: "https://github.com/oneblacki/crm",
  },
  {
    id: "3",
    title: "Task Management App",
    description:
      "Aplicativo de gerenciamento de tarefas inspirado no Trello com arrastar e soltar.",
    image: "/images/placeholder.jpg",
    tags: [
      { id: "7", name: "React" },
      { id: "8", name: "Firebase" },
      { id: "9", name: "Tailwind CSS" },
    ],
    demoUrl: "https://example.com",
    repoUrl: "https://github.com/oneblacki/task-app",
  },
];

export function ProjectsSection({ data }: { data?: ProjectsData }) {
  const ref = useRef(null);
  const isInView = useInView(ref, { once: true, margin: "-100px" });
  const projects = data?.projects || SAMPLE_PROJECTS;

  return (
    <section id="projects" className="section-padding" ref={ref}>
      <div className="container mx-auto px-4">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={isInView ? { opacity: 1, y: 0 } : {}}
          transition={{ duration: 0.6 }}
          className="max-w-3xl mx-auto text-center mb-16"
        >
          <h2 className="section-title">Projetos</h2>
        </motion.div>
        {projects.map((project, index) => (
          <ProjectCard key={project.id} project={project} index={index} />
        ))}
      </div>
        </section>
      );
    }