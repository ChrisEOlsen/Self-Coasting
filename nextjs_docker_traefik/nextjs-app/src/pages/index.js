export default function HomePage() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center bg-gray-900 text-white p-8">
      <div className="text-center space-y-6 max-w-2xl">
        
        {/* Main Heading */}
        <h1 className="text-5xl md:text-6xl font-extrabold tracking-tight text-transparent bg-clip-text bg-gradient-to-r from-purple-400 to-pink-600">
          Next.js & Docker Template
        </h1>
        
        {/* Subheading / Instructions */}
        <p className="text-lg text-gray-400">
          Your site is up and running successfully! You can start building your page by editing the file at:
        </p>

        {/* Code block to show the file path */}
        <div className="flex justify-center">
            <code className="bg-gray-800 font-mono text-sm rounded-md px-4 py-2 text-pink-400 border border-gray-700">
                nextjs-app/app/page.js
            </code>
        </div>
        
        {/* Example Button */}
        <div className="pt-4">
          <a
            href="https://tailwindcss.com/docs"
            target="_blank"
            rel="noopener noreferrer"
            className="inline-block bg-indigo-600 text-white font-semibold px-6 py-3 rounded-lg shadow-lg hover:bg-indigo-700 transition-colors duration-300"
          >
            Learn Tailwind CSS
          </a>
        </div>

      </div>
    </main>
  );
}
