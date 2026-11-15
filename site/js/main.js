function handleMobileNav() {
  const mobileToggle = document.querySelector("[data-mobile-toggle]");
  const navigation = document.querySelector("[data-navigation]");

  mobileToggle.addEventListener("click", () => {
    navigation.classList.toggle("open");
    mobileToggle.classList.toggle("active");
  });

  document.documentElement.addEventListener("click", (event) => {
    if (!mobileToggle.contains(event.target) && !navigation.contains(event.target)) {
      navigation.classList.remove("open");
      mobileToggle.classList.remove("active");
    }
  });
}

function handleContactForm() {
  const form = document.querySelector('form[name="contact"]');
  if (!form) return;

  const confirmation = document.querySelector(".form-confirmation");

  form.addEventListener("submit", (event) => {
    event.preventDefault();
    const formData = new FormData(form);

    fetch("/", {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams(formData).toString(),
    })
      .then(() => {
        form.style.display = "none";
        if (confirmation) confirmation.style.display = "block";
      })
      .catch(() => {
        form.style.display = "none";
        if (confirmation) confirmation.style.display = "block";
      });
  });
}

function handleSmoothScroll() {
  document.querySelectorAll('a[href^="#"]').forEach((anchor) => {
    anchor.addEventListener("click", (event) => {
      const target = document.querySelector(anchor.getAttribute("href"));
      if (target) {
        event.preventDefault();
        target.scrollIntoView({ behavior: "smooth" });
        // Close mobile nav if open
        document.querySelector("[data-navigation]")?.classList.remove("open");
        document.querySelector("[data-mobile-toggle]")?.classList.remove("active");
      }
    });
  });
}

document.addEventListener("DOMContentLoaded", () => {
  handleMobileNav();
  handleContactForm();
  handleSmoothScroll();
});
