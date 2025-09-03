export async function createChatSession(token, title, initialMessage, tone) {
  const response = await fetch("http://localhost:3000/chat_sessions", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Accept: "*/*",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({
      title,
      initial_message: initialMessage,
      tone: tone,
    }),
  });

  if (!response.ok) throw new Error("Failed to create chat session");
  return response.json();
}

export async function sendMessage(token, chatSessionId, content, tone) {
  const response = await fetch(
    `http://localhost:3000/chat_sessions/${chatSessionId}/messages`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Accept: "*/*",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({ content, tone }),
    }
  );

  if (!response.ok) throw new Error("Failed to send message");
  return response.json();
}

export async function summarizeChat(token, chatSessionId) {
  const response = await fetch(`http://localhost:3000/chat_sessions/${chatSessionId}/summarize`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Accept: "*/*",
      Authorization: `Bearer ${token}`,
    },
  });

  if (!response.ok) throw new Error("Failed to summarize chat");

  return response.json();
}