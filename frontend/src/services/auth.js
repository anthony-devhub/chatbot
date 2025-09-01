export async function login(email, password) {
  const response = await fetch("http://localhost:3000/users/signin", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Accept: "*/*",
    },
    body: JSON.stringify({ email, password }),
  });

  if (!response.ok) {
    throw new Error("Login failed");
  }

  return response.json();
}

export async function signup(email, password, password_confirmation) {
  const response = await fetch("http://localhost:3000/users/signup", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Accept: "*/*",
    },
    body: JSON.stringify({
      user: {
        email,
        password,
        password_confirmation,
      },
    }),
  });

  if (!response.ok) {
    throw new Error("Registration failed");
  }

  return response.json();
}