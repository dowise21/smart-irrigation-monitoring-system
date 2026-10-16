var registerForm = document.getElementById('registerForm');
var registerMessage = document.getElementById('registerMessage');

function showRegisterMessage(message, isError) {
	registerMessage.textContent = message;
	registerMessage.classList.toggle('is-error', isError);
	registerMessage.hidden = false;
}

document.querySelectorAll('[data-toggle-password]').forEach(function (button) {
	button.addEventListener('click', function () {
		var input = document.getElementById(button.getAttribute('data-toggle-password'));
		var show = input.type === 'password';
		input.type = show ? 'text' : 'password';
		button.setAttribute('aria-label', show ? 'Hide password' : 'Show password');
	});
});

registerForm.addEventListener('input', function () {
	registerMessage.hidden = true;
});

registerForm.addEventListener('submit', function (event) {
	event.preventDefault();
	registerMessage.hidden = true;

	if (!registerForm.reportValidity()) return;

	var fullName = document.getElementById('fullName').value.trim();
	var email = document.getElementById('registerEmail').value.trim();
	var password = document.getElementById('registerPassword').value;
	var confirmPassword = document.getElementById('confirmPassword').value;
	if (password.length < 8) {
		showRegisterMessage('Use a password with at least 8 characters.', true);
		return;
	}
	if (password !== confirmPassword) {
		showRegisterMessage('The passwords do not match.', true);
		return;
	}

	var params = new URLSearchParams();
	params.set('fullName', fullName);
	params.set('email', email);
	params.set('password', password);
	params.set('confirmPassword', confirmPassword);

	fetch('register', {
		method: 'POST',
		headers: {
			'Content-Type': 'application/x-www-form-urlencoded',
			'X-Requested-With': 'fetch'
		},
		body: params.toString()
	})
		.then(function (res) {
			return res.json().then(function (data) {
				return { ok: res.ok && data.ok, message: data.message };
			});
		})
		.then(function (result) {
			showRegisterMessage(result.message || (result.ok ? 'Account created successfully.' : 'Registration failed.'), !result.ok);
			if (result.ok) {
				registerForm.reset();
			}
		})
		.catch(function () {
			showRegisterMessage('Could not connect to the server. Please try again.', true);
		});
});
