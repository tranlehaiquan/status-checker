import "./App.css";
import { Button } from "@/components/ui/button";

function App() {
  return (
    <div>
      {import.meta.env.VITE_BE_URL}
      <Button>Click me</Button>
    </div>
  );
}

export default App;
