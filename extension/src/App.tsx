import { useEffect, useState } from "react";

function App() {
  const [loading, setLoading] = useState<boolean>(true);
  
  useEffect(() => {
    setLoading(false);
  }, []);
  
  return (
    <div className="w-full h-screen bg-black text-white font-md flex justify-center items-center">
      <h1>{loading ? "Loading..." : "Hello world from nvim"}</h1>
    </div>
  );
}

export default App;