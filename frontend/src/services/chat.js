export async function createChatSession(token, title, initialMessage) {
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
    }),
  });

  if (!response.ok) throw new Error("Failed to create chat session");
  return response.json();
}

export async function sendMessage(token, chatSessionId, content) {
  const response = await fetch(
    `http://localhost:3000/chat_sessions/${chatSessionId}/messages`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Accept: "*/*",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify({ content }),
    }
  );

  if (!response.ok) throw new Error("Failed to send message");
  return response.json();
}
