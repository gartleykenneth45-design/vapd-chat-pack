window.addEventListener('message', function(event) {

    const data = event.data;

    if (data.action === 'addMessage') {

        const container = document.getElementById('chat-container');

        const message = document.createElement('div');

        message.innerHTML = data.html;

        container.appendChild(message);

        setTimeout(() => {
            message.remove();
        }, 10000);
    }

});