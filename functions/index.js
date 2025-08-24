const functions = require("firebase-functions/v2/https");
const axios = require("axios");

// Deploy with: firebase deploy --only functions
exports.createForm = functions.onRequest(async (req, res) => {
  if (req.method !== "POST") {
    return res.status(405).send("Only POST allowed");
  }

  const { accessToken, topic, questions } = req.body;

  if (!accessToken || !questions || !Array.isArray(questions)) {
    return res.status(400).json({ error: "Missing data" });
  }

  try {
    // Step 1: Create Form
    const createFormRes = await axios.post(
      "https://forms.googleapis.com/v1/forms",
      {
        info: {
          title: `${topic || "AI Quiz"} - Quiz`,
          documentTitle: `${topic || "AI Quiz"} - Quiz`,
        },
      },
      {
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
      }
    );

    const formId = createFormRes.data.formId;

    // Step 2: Add questions
    const requests = questions.map((q, index) => ({
      createItem: {
        item: {
          title: q.question,
          questionItem: {
            question: {
              required: true,
              choiceQuestion: {
                type: "RADIO",
                options: q.options.map((opt) => ({ value: opt })),
                shuffle: false,
              },
            },
          },
        },
        location: { index },
      },
    }));

    await axios.post(
      `https://forms.googleapis.com/v1/forms/${formId}:batchUpdate`,
      { requests },
      {
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
      }
    );

    const editUrl = `https://docs.google.com/forms/d/${formId}/edit`;
    res.json({ success: true, editUrl });

  } catch (err) {
    console.error(err.response?.data || err.message);
    res.status(500).json({ error: "Failed to create form" });
  }
});
