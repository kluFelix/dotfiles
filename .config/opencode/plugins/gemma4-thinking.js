export const server = async () => {
  return {
    "experimental.chat.messages.transform": async (_input, output) => {
      const messages = output.messages;
      if (!Array.isArray(messages) || messages.length === 0) return;

      const last = messages[messages.length - 1];
      if (!last || last.info.role !== "user") return;

      const model = last.info.model;
      if (!model || model.providerID !== "llama.cpp" || !(model.modelID.startsWith("Gemma4"))) {
        return;
      }

      const firstTextPart = last.parts.find((part) => part.type === "text");
      if (!firstTextPart) return;

      if (typeof firstTextPart.text !== "string") return;
      if (firstTextPart.text.startsWith("<|think|>")) return;

      firstTextPart.text = `<|think|>${firstTextPart.text}`;
    },
  };
};

