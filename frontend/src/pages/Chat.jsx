import { useState, useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { AppBar, Toolbar, Button, TextField, Box, Typography, Paper, ToggleButton, ToggleButtonGroup } from "@mui/material";
import { createChatSession, sendMessage, summarizeChat } from "../services/chat";

export default function ChatPage() {
  const [chatSessionId, setChatSessionId] = useState(null);
  const [messages, setMessages] = useState([]);
  const [input, setInput] = useState("");
  const [tone, setTone] = useState("friendly");
  const token = localStorage.getItem("token");

  const navigate = useNavigate();

  useEffect(() => {
    if (!token) {
      navigate("/login");
    }
  }, [navigate]);

  const handleSignOut = () => {
    localStorage.removeItem("token");
    navigate("/login");
  };

  const handleSend = async () => {
    if (!input.trim()) return;

    try {
      if (!chatSessionId) {
        // First-time chat
        const data = await createChatSession(token, "Chat with AI", input, tone);
        setChatSessionId(data.chat_session.id);

        setMessages([
          { role: "user", content: data.user_message.content },
          { role: "assistant", content: data.ai_message.content },
        ]);
      } else {
        // Continuing chat
        const data = await sendMessage(token, chatSessionId, input, tone);
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

  const handleSummarize = async () => {
  if (!chatSessionId) {
    alert("No chat session to summarize yet!");
    return;
  }

  try {
    const data = await summarizeChat(token, chatSessionId);
    setMessages((prev) => [
      ...prev,
      { role: "assistant", content: data.ai_message.content },
    ]);
  } catch (err) {
    console.error(err);
    alert("Failed to summarize chat");
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

      <ToggleButtonGroup
        value={tone}
        exclusive
        onChange={(e, newTone) => {
          if (newTone) setTone(newTone);
        }}
        sx={{ mb: 2 }}
      >
        <ToggleButton value="friendly">😊 Friendly</ToggleButton>
        <ToggleButton value="sarcastic">😏 Sarcastic</ToggleButton>
        <ToggleButton value="professional">💼 Professional</ToggleButton>
        <ToggleButton value="mentor">🎓 Mentor</ToggleButton>
      </ToggleButtonGroup>

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
        <Button variant="outlined" color="secondary" onClick={handleSummarize}>
          Summarize Chat
        </Button>
      </Box>
    </Box>
  );
}
