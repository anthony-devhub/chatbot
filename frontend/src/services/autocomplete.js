export async function autoComplete(token, chatSessionId, text) {
  const response = await fetch(`http://localhost:3000/chat_sessions/${chatSessionId}/suggestions?partial_content=${text}`, {
    method: "GET",
    headers: {
      "Content-Type": "application/json",
      Accept: "*/*",
      Authorization: `Bearer ${token}`,
    },
  });

  if (!response.ok) throw new Error("Failed to create chat session");
  return response.json();
}