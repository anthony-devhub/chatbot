import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import { AppBar, Toolbar, Button, TextField, Box, Typography } from "@mui/material";

export default function ChatPage() {
  const navigate = useNavigate();

  const handleSignOut = () => {
    localStorage.removeItem("token");
    navigate("/login");
  };

  useEffect(() => {
    const token = localStorage.getItem("token");
    if (!token) {
      navigate("/login");
    }
  }, [navigate]);

  return (
    <Box display="flex" flexDirection="column" alignItems="center" mt={10} width={800}>
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

      <Box
        display="flex"
        flexDirection="column"
        gap={2}
        width="100%"
      >
        <TextField label="Type your message" fullWidth />
        <Button variant="contained" color="primary">
          Send
        </Button>
      </Box>
    </Box>
  );
}
