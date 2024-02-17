function toggleMenu() {
    const menu = document.querySelector(".menu-links");
    const icon = document.querySelector(".hamburger-icon");
    menu.classList.toggle("open")
    icon.classList.toggle("open")
}

// Send request to the api to get the number of views.
async function updateCount(page) {
    const website = "www.slapointe.com";
    let url =`https://func-cloudresume-ryupr-apim.azure-api.net/cloudresume/updateviews?website=${website}&page=${page}`

    let response = await fetch(url);

if (response.ok) {
    let data = await response.json();
    document.getElementById("views-count").innerHTML = `Views: ${data.views}`
} else {
    document.getElementById("views-count").innerHTML = "Views: Error fetching views"
}
}