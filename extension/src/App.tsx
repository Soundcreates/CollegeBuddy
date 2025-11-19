
import "./App.css";
import { handleGoogleAuth } from "./api/googleApi";



function App() {
  


  const handleGoogleClick = async () => {
    console.log("Approaching google");
    await handleGoogleAuth();
  }


  return (
    <div className="extension-popup bg-white font-md caveat-font text-[#F5F1DC] flex justify-center items-center">
      <div className = "w-[100%] h-[100%] flex flex-col justify-center items-center bg-[#fffff] ">

        <h1  className="text-[50px] lexend-font text-black fade-down font-bold mb-6">CollegeBuddy</h1>

        <button onClick = {  handleGoogleClick} className="brutal-btn scale-up-and-pop lexend-font">{"Get Started with google"}</button>

        </div>
    </div>
  );
}

export default App;
