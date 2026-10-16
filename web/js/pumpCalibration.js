const button =
    document.getElementById("calibrateButton");

const progressBar =
    document.getElementById("progressBar");

const progressText =
    document.getElementById("progressText");


button.addEventListener("click", function() {

    button.disabled = true;

    button.textContent =
        "Calibrating...";


    let progress = 0;


    const timer =
        setInterval(function() {

            progress += 10;

            progressBar.style.width =
                progress + "%";

            progressText.textContent =
                "Calibration progress: " +
                progress + "%";


            if (progress >= 100) {

                clearInterval(timer);

                progressText.textContent =
                    "Calibration completed successfully.";

                button.textContent =
                    "Calibration Completed";

                button.disabled = false;

            }

        }, 300);

});