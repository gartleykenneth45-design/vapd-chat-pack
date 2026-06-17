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
        addStructuredMessage(data);
    }

    if (data.action === 'addRawHtml') {
        addRawMessage(data.html);
    }

    if (data.action === 'openChat') {
        openChat(data.prefix || '');
    }

    if (data.action === 'closeChat') {
        closeChat();
    }
});

function createTextNode(text) {
    return document.createTextNode(text);
}

function createSpan(className, text) {
    var span = document.createElement('span');
    span.className = className;
    span.textContent = text;
    return span;
}

function addStructuredMessage(data) {
    var el = document.createElement('div');
    el.classList.add('chat-msg');

    switch (data.type) {
        case 'local':
            el.classList.add('msg-local');
            if (data.name) {
                el.appendChild(createSpan('msg-name', data.name));
                el.appendChild(createTextNode(': ' + data.message));
            } else {
                el.appendChild(createTextNode(data.message));
            }
            break;

        case 'me':
            el.classList.add('msg-me');
            el.textContent = '* ' + data.message + ' *';
            break;

        case 'twt':
            el.classList.add('msg-twt');
            el.appendChild(createSpan('msg-icon', '\uD83D\uDC26'));
            el.appendChild(createTextNode(' '));
            el.appendChild(createSpan('msg-tag', '@' + data.name));
            el.appendChild(createTextNode(': ' + data.message));
            break;

        case 'blackweb':
            el.classList.add('msg-blackweb');
            el.appendChild(createSpan('msg-icon', '\uD83D\uDD77\uFE0F'));
            el.appendChild(createTextNode(' '));
            el.appendChild(createSpan('msg-tag', 'BLACKWEB'));
            el.appendChild(createTextNode(': ' + data.message));
            break;

        case 'ooc':
            el.classList.add('msg-ooc');
            el.appendChild(createTextNode('(( '));
            el.appendChild(createSpan('msg-name', data.name));
            el.appendChild(createTextNode(': ' + data.message + ' ))'));
            break;

        default:
            el.classList.add('msg-local');
            el.textContent = data.message || '';
            break;
    }

    appendMessage(el);
}

function addRawMessage(html) {
    var el = document.createElement('div');
    el.classList.add('chat-msg', 'msg-local');
    el.textContent = html;
    appendMessage(el);
}

function appendMessage(el) {
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
