// Get the "Start Translation" button
const startButton = document.getElementById('start');

// Add click event listener to the button
startButton.addEventListener('click', () => {
    // Send a message to start the translation process
    chrome.tabs.query({ active: true, currentWindow: true }, (tabs) => {
        chrome.tabs.sendMessage(tabs[0].id, { action: "startTranslation" });
    });

    // Change button text to "Started"
    startButton.innerText = 'Started';

    // Optionally, disable the button to prevent clicking again
    startButton.disabled = true;
});