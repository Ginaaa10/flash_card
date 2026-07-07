const express = require('express');
const bodyParser = require('body-parser');
const axios = require('axios');

const app = express();
app.use(bodyParser.json({ limit: '5mb' }));

// POST /generate
// body: { text: "..." }
// If OPENAI_API_KEY is set in env, the server will call OpenAI Chat Completions API to generate questions.
// Otherwise it returns a small dummy response so you can run the app locally without API key.
app.post('/generate', async (req, res) => {
  try {
    const { text } = req.body || {};
    if (!text || text.trim().length === 0) return res.status(400).json({ error: 'Missing text' });

    const OPENAI_KEY = process.env.OPENAI_API_KEY;
    if (!OPENAI_KEY) {
      // Return a deterministic dummy response for local testing
      const dummy = [
        { type: 'mcq', question: 'MCQ mẫu: Quang hợp xảy ra ở đâu?', choices: ['Lá', 'Rễ', 'Thân', 'Hoa'], correct_index: 0, explanation: 'Quang hợp xảy ra ở lá.' },
        { type: 'essay', prompt: 'Giải thích ngắn về quá trình quang hợp.' }
      ];
      return res.json(JSON.stringify(dummy, null, 2));
    }

    const prompt = `Bạn là trợ lý giáo dục. Từ nội dung sau, tạo:
1) 5 câu trắc nghiệm (multiple-choice) với 4 lựa chọn mỗi câu, chỉ 1 đáp án đúng.
2) 3 câu tự luận (essay prompts).
Trả về dưới dạng JSON mảng. Mỗi phần tử là object có 'type' = 'mcq' hoặc 'essay'. Không kèm lời giải thích ngoài JSON. Văn bản đầu vào:\n\n"""\n${text}\n"""\nNgôn ngữ: tiếng Việt.`;

    const resp = await axios.post('https://api.openai.com/v1/chat/completions', {
      model: 'gpt-4',
      messages: [
        { role: 'system', content: 'You are an educational content generator that must return valid JSON only.' },
        { role: 'user', content: prompt }
      ],
      max_tokens: 1500,
      temperature: 0.2,
    }, {
      headers: { 'Authorization': `Bearer ${OPENAI_KEY}` }
    });

    const assistant = resp.data?.choices?.[0]?.message?.content || '';
    // Try to parse assistant content as JSON; if fails return raw text so client can show it for debugging
    try {
      const parsed = JSON.parse(assistant);
      return res.json(JSON.stringify(parsed, null, 2));
    } catch (e) {
      return res.json(assistant);
    }
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.toString() });
  }
});

const port = process.env.PORT || 8080;
app.listen(port, () => console.log(`Question server listening on ${port}`));
