const loginForm = document.getElementById("loginForm");

if (loginForm) {
    loginForm.addEventListener("submit", function (event) {
        if (!loginForm.checkValidity()) {
            event.preventDefault();
            loginForm.reportValidity();
        }
    });
}