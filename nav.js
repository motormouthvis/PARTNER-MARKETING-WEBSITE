/* Dream Neighborhood — Bill review site nav.
   Builds the mobile hamburger menu from the existing desktop
   nav markup so every / page stays in sync automatically.
   The main site (/) never loads this file. */
(function () {
  var nav = document.querySelector(".nav");
  if (!nav) return;
  var inner = nav.querySelector(".nav__inner");
  var links = nav.querySelector(".nav__links");
  if (!inner || !links) return;
  var cta = nav.querySelector(".nav__cta");

  // Hamburger button
  var burger = document.createElement("button");
  burger.type = "button";
  burger.className = "nav__burger";
  burger.setAttribute("aria-label", "Toggle navigation menu");
  burger.setAttribute("aria-expanded", "false");
  burger.innerHTML = "<span></span><span></span><span></span>";
  inner.appendChild(burger);

  // Mobile panel cloned from the desktop nav
  var panel = document.createElement("div");
  panel.className = "nav__mobile";
  panel.appendChild(links.cloneNode(true));
  if (cta) panel.appendChild(cta.cloneNode(true));
  nav.appendChild(panel);

  function close() {
    nav.classList.remove("is-open");
    burger.setAttribute("aria-expanded", "false");
  }

  burger.addEventListener("click", function () {
    var open = nav.classList.toggle("is-open");
    burger.setAttribute("aria-expanded", open ? "true" : "false");
  });

  // Close after tapping a real link
  panel.addEventListener("click", function (e) {
    if (e.target.closest("a")) close();
  });

  // Close on Escape and when resizing back to desktop
  document.addEventListener("keydown", function (e) {
    if (e.key === "Escape") close();
  });
  window.addEventListener("resize", function () {
    if (window.innerWidth > 1200) close();
  });
})();
