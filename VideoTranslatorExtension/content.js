chrome.runtime.onMessage.addListener((message) => {
    if (message.action === "startTranslation") {
        translateSubtitles();
    }
});

async function translateSubtitles() {
    // Get all the subtitle elements on the page
    let subtitles = document.querySelectorAll(".ytp-caption-segment");

    // If subtitles aren't found, try another class name
    if (subtitles.length === 0) {
        subtitles = document.querySelectorAll(".captions-text");
    }

    // If no subtitles are found, log an error
    if (subtitles.length === 0) {
        console.error("No subtitles detected! Ensure subtitles are enabled on YouTube.");
        return;
    }

    console.log("Subtitles found:", subtitles);

    // Translate and style each subtitle
    for (let subtitle of subtitles) {
        let text = subtitle.innerText;
        if (text) {
            console.log("Original text:", text);

            let translatedText = await translateText(text);  // Google Translation API
            console.log("Translated text:", translatedText);

            subtitle.innerText = translatedText;  // Replace with translated text

            // Apply custom styling to the subtitle
            subtitle.style.fontFamily = "'Times New Roman', sans-serif";  // Change font
            subtitle.style.fontSize = "18px";                  // Font size
            subtitle.style.color = "#FFD700";                  // Gold color
            subtitle.style.backgroundColor = "rgba(0, 0, 0, 0.6)";  // Semi-transparent black background
            subtitle.style.padding = "5px";                    // Padding
            subtitle.style.borderRadius = "8px";               // Rounded corners
            subtitle.style.textAlign = "center";               // Center text
            subtitle.style.boxShadow = "0px 0px 10px rgba(0, 0, 0, 0.5)";  // Add shadow
        }
    }
}

async function translateText(text) {
    const API_KEY = "YOUR_API";  
    const url = `https://translation.googleapis.com/language/translate/v2?key=${API_KEY}`;

    try {
        let response = await fetch(url, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ q: text, source: "hi", target: "en" }) // Hindi to English
        });

        if (!response.ok) {
            throw new Error(`Translation API failed with status: ${response.status}`);
        }

        let data = await response.json();

        if (data.data && data.data.translations) {
            return data.data.translations[0].translatedText;
        } else {
            console.error("Translation error:", data);
            return text;  // Fallback to original text
        }
    } catch (error) {
        console.error("Translation API request failed:", error);
        return text;  // Fallback in case of an error
    }
}

