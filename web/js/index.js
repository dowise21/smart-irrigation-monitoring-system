// ================= SENSOR DATA =================

const temperature =
    document.getElementById("temperature");

const humidity =
    document.getElementById("humidity");

const moisture =
    document.getElementById("moisture");


function updateSensorData() {

    let temp =
        Math.floor(Math.random() * 5) + 26;

    let hum =
        Math.floor(Math.random() * 10) + 65;

    let soil =
        Math.floor(Math.random() * 10) + 70;


    temperature.textContent = temp;

    humidity.textContent = hum;

    moisture.textContent = soil;

}


setInterval(updateSensorData, 3000);


// ================= COUNTER =================

const counters =
    document.querySelectorAll(".counter");


counters.forEach(function(counter) {

    let target =
        Number(counter.dataset.target);

    let value = 0;


    let timer =
        setInterval(function() {

            value++;

            counter.textContent = value;


            if (value >= target) {

                clearInterval(timer);

            }

        }, 20);

});