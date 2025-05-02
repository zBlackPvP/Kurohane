import React from 'react';
// import Link from 'next/link'; // Para navegação interna otimizada

export default function HomePage() {
  return (
    <div className="container mx-auto flex min-h-screen flex-col items-center justify-center p-6 md:p-8">
      <header className="mb-10 text-center">
        <h1 className="mb-3 text-4xl font-bold text-accent-blue sm:text-5xl md:text-6xl font-mono">
          OneBlackI Systems
        </h1>
        <p className="text-md text-text-secondary sm:text-lg font-sans">
          Uma visão cinza sobre engenharia, filosofia e criação.
        </p>
      </header>

      <section className="max-w-3xl text-center font-sans text-base sm:text-lg">
        <p className="mb-6">
          Explorando a intersecção entre o técnico e o existencial. Este espaço
          documenta projetos, reflexões e fragmentos de um universo conceitual
          em construção.
        </p>
        {/* Exemplo de link futuro */}
        {/* <Link href="/sobre" className="text-accent-red hover:underline">
          [ Iniciar Exploração ]
        </Link> */}
         <p className="mt-4 text-sm text-accent-red">[ Em Desenvolvimento ]</p>
      </section>

      {/* <footer className="mt-12 text-center text-sm text-text-secondary">
        Navegação: [Sobre] [Projetos] [Textos] [Contato]
      </footer> */}
    </div>
  );
}