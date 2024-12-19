import "./App.css";
import StatusCheck from "./features/statusCheck/StatusCheck";

function App() {
  return (
    <div>
      <h1 className="text-3xl font-bold text-center mb-6">
        Check website status from multiple regions
      </h1>

      <StatusCheck />
    </div>
  );
}

export default App;
