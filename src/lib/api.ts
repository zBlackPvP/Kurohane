import { db } from "./db";

/**
 * Get all projects with optional filtering
 */
export async function getProjects({
  featured,
  limit,
}: {
  featured?: boolean;
  limit?: number;
} = {}) {
  try {
    const projects = await db.project.findMany({
      where: featured ? { featured: true } : {},
      take: limit,
      orderBy: { createdAt: "desc" },
      include: {
        tags: true,
        user: {
          select: {
            name: true,
            image: true,
          },
        },
      },
    });

    return projects;
  } catch (error) {
    console.error("Database Error:", error);
    throw new Error("Failed to fetch projects");
  }
}

/**
 * Get a single project by ID
 */
export async function getProject(id: string) {
  try {
    const project = await db.project.findUnique({
      where: { id },
      include: {
        tags: true,
        user: {
          select: {
            name: true,
            image: true,
          },
        },
      },
    });

    return project;
  } catch (error) {
    console.error("Database Error:", error);
    throw new Error("Failed to fetch project");
  }
}

/**
 * Get all skills with optional category filtering
 */
export async function getSkills(category?: string) {
  try {
    const skills = await db.skill.findMany({
      where: category ? { category } : {},
      orderBy: { level: "desc" },
    });

    return skills;
  } catch (error) {
    console.error("Database Error:", error);
    throw new Error("Failed to fetch skills");
  }
}

/**
 * Get all experiences ordered by date
 */
export async function getExperiences() {
  try {
    const experiences = await db.experience.findMany({
      orderBy: [
        { current: "desc" },
        { endDate: "desc" },
        { startDate: "desc" },
      ],
    });

    return experiences;
  } catch (error) {
    console.error("Database Error:", error);
    throw new Error("Failed to fetch experiences");
  }
}

/**
 * Submit a contact form
 */
export async function submitContactForm({
  name,
  email,
  message,
}: {
  name: string;
  email: string;
  message: string;
}) {
  try {
    const contact = await db.contact.create({
      data: {
        name,
        email,
        message,
      },
    });

    return contact;
  } catch (error) {
    console.error("Database Error:", error);
    throw new Error("Failed to submit contact form");
  }
}