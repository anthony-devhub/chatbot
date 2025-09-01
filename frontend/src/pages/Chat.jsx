import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { AppBar, Toolbar, Button, TextField, Box, Typography, Paper } from "@mui/material";
import { createChatSession, sendMessage } from "../services/chat";

export default function ChatPage() {
  const [chatSessionId, setChatSessionId] = useState(null);
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState("");
  const token = localStorage.getItem("token");

  const navigate = useNavigate();

  const handleSignOut = () => {
    localStorage.removeItem("token");
    navigate("/login");
  };

  useEffect(() => {
    if (!token) {
      navigate("/login");
    }
  }, [navigate]);

  const handleSend = async () => {
    if (!input.trim()) return;

    try {
      if (!chatSessionId) {
        // First-time chat
        const data = await createChatSession(token, "Chat with AI", input);
        setChatSessionId(data.chat_session.id);

        setMessages([
          { role: "user", content: data.user_message.content },
          { role: "assistant", content: data.ai_message.content },
        ]);
      } else {
        // Continuing chat
        const data = await sendMessage(token, chatSessionId, input);
        setMessages((prev) => [
          ...prev,
          { role: "user", content: data.user_message.content },
          { role: "assistant", content: data.ai_message.content },
        ]);
      }
      setInput("");
    } catch (err) {
      console.error(err);
      alert("Something went wrong");
    }
  };

  return (
    <Box display="flex" flexDirection="column" alignItems="center" mt={2} width={800}>
      <AppBar position="static">
        <Toolbar>
          <Typography variant="h6" sx={{ flexGrow: 1 }}>
            Chat Room
          </Typography>
          <Button color="inherit" onClick={handleSignOut}>
            Sign Out
          </Button>
        </Toolbar>
      </AppBar>

      <Paper
        elevation={3}
        sx={{
          p: 2,
          width: "100%",
          height: 300,
          overflowY: "auto",
          mb: 2,
          mt: 5,
        }}
      >
        {messages.map((msg, i) => (
          <Typography
            key={i}
            align={msg.role === "user" ? "right" : "left"}
            color={msg.role === "user" ? "primary" : "secondary"}
          >
            {msg.content}
          </Typography>
        ))}
      </Paper>

      <Box
        display="flex"
        flexDirection="column"
        gap={2}
        width="100%"
      >
        <TextField
          label="Type your message"
          fullWidth
          value={input}
          onChange={(e) => setInput(e.target.value)}
        />
        <Button variant="contained" color="primary" onClick={handleSend}>
          Send
        </Button>
      </Box>
    </Box>
  );
}
