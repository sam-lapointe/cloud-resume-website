function toggleMenu() {
    const menu = document.querySelector(".menu-links");
    const icon = document.querySelector(".hamburger-icon");
    menu.classList.toggle("open")
    icon.classList.toggle("open")
}

async function updateCount(page) {
    const website = "www.slapointe.com";
    let url = `https://api.slapointe.com/api/updateviewscount?website=${website}&page=${page}`;

    let response = await fetch(url);

if (response.ok) {
    let data = await response.json();
    document.getElementById("views-count").innerHTML = `Views: ${data.views}`
} else {
    document.getElementById("views-count").innerHTML = "Views: Error fetching views"
}
}