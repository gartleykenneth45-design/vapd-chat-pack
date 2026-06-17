var chatMessages = document.getElementById('chat-messages');
var chatInputWrapper = document.getElementById('chat-input-wrapper');
var chatInput = document.getElementById('chat-input');

var MSG_DURATION = 10000;
var FADE_DURATION = 500;
var MAX_MESSAGES = 50;

function getResourceName() {
    if (typeof GetParentResourceName === 'function') {
        return GetParentResourceName();
    }
    return 'vpdchat';
}

window.addEventListener('message', function (event) {
    var data = event.data;

    if (data.action === 'addMessage') {
        addMessage(data.html);
    }

    if (data.action === 'openChat') {
        openChat(data.prefix || '');
    }

    if (data.action === 'closeChat') {
        closeChat();
    }
});

function addMessage(html) {
    var temp = document.createElement('div');
    temp.innerHTML = html.trim();
    var el = temp.firstElementChild;

    if (!el) {
        el = document.createElement('div');
        el.classList.add('msg-local');
        el.textContent = html;
    }

    el.classList.add('chat-msg');
    chatMessages.appendChild(el);

    while (chatMessages.children.length > MAX_MESSAGES) {
        chatMessages.removeChild(chatMessages.firstChild);
    }

    chatMessages.scrollTop = chatMessages.scrollHeight;

    setTimeout(function () {
        el.classList.add('fade-out');
        setTimeout(function () {
            if (el.parentNode) {
                el.parentNode.removeChild(el);
            }
        }, FADE_DURATION);
    }, MSG_DURATION);
}

function openChat(prefix) {
    chatInputWrapper.classList.remove('hidden');
    chatInput.value = prefix;
    chatInput.focus();
}

function closeChat() {
    chatInputWrapper.classList.add('hidden');
    chatInput.value = '';
    chatInput.blur();
}

chatInput.addEventListener('keydown', function (e) {
    e.stopPropagation();

    if (e.key === 'Enter') {
        e.preventDefault();
        var msg = chatInput.value.trim();
        closeChat();

        if (msg !== '') {
            fetch('https://' + getResourceName() + '/sendMessage', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ message: msg })
            });
        } else {
            fetch('https://' + getResourceName() + '/closeChat', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
        }
    }

    if (e.key === 'Escape') {
        e.preventDefault();
        closeChat();
        fetch('https://' + getResourceName() + '/closeChat', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    }
});
