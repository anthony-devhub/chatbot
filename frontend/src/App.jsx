import { BrowserRouter as Router, Routes, Route } from "react-router-dom";
import LoginPage from "./pages/Login";
import ChatPage from "./pages/Chat";
import RegistrationPage from "./pages/Registration";
import './App.css'

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/login" element={<LoginPage />} />
        <Route path="/" element={<ChatPage />} />
        <Route path="/signup" element={<RegistrationPage />} />
        {/* Add more routes here */}
      </Routes>
    </Router>
  )
}

export default App
