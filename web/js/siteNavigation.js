(function () {
    var navToggle = document.getElementById("navToggle");
    var mainNav = document.getElementById("mainNav");
    var bellButton = document.getElementById("bellBtn");
    var alertMenu = document.getElementById("alertMenu");
    var alertList = document.getElementById("alertList");
    var bellBadge = document.getElementById("bellBadge");
    var alertCenter = window.IrrigationAlertCenter;
    var ctx = window.SI_CTX || "";

    function escapeHtml(value) {
        return String(value).replace(/[&<>"']/g, function (character) {
            return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[character];
        });
    }

    function initialsFor(name) {
        var parts = String(name || "User").trim().split(/\s+/);
        if (parts.length >= 2) {
            return (parts[0].charAt(0) + parts[parts.length - 1].charAt(0)).toUpperCase();
        }
        return String(name || "US").slice(0, 2).toUpperCase();
    }

    var access = window.SI_ACCESS || {};
    var readSet = Array.isArray(access.read) ? access.read : null;
    var writeSet = Array.isArray(access.write) ? access.write : null;
    var permSet = Array.isArray(access.permissions) ? access.permissions : null;

    window.SI_CAN = {
        role: function () {
            return (window.SI_USER && window.SI_USER.role) || access.role || "";
        },
        read: function (route) {
            if (!readSet) return true;
            return readSet.indexOf(route) !== -1;
        },
        write: function (route) {
            if (!writeSet) return true;
            return writeSet.indexOf(route) !== -1;
        },
        perm: function (permName) {
            if (window.SI_USER && window.SI_USER.role === "ADMIN") return true;
            if (!permSet) return true;
            return permSet.indexOf(String(permName).toUpperCase()) !== -1;
        }
    };

    function applyUserAndAccess() {
        var user = window.SI_USER;
        if (user) {
            var displayName = user.name || user.username || "User";
            var label = user.role ? (displayName + " · " + user.role) : displayName;
            document.querySelectorAll(".user-chip, .user-chip-wrap").forEach(function (el) {
                el.title = label;
                el.setAttribute("aria-label", label);
            });
            document.querySelectorAll(".avatar").forEach(function (el) {
                el.textContent = initialsFor(displayName);
            });
            document.querySelectorAll(".role-badge").forEach(function (badge) {
                if (user.role) {
                    badge.textContent = user.role;
                    badge.className = "role-badge role-" + user.role.toLowerCase();
                }
            });
        }

        document.querySelectorAll("a.btn-logout").forEach(function (link) {
            link.href = ctx + "/logout";
        });

        if (access.nav && Array.isArray(access.nav)) {
            document.querySelectorAll("#mainNav a[href]").forEach(function (link) {
                var href = link.getAttribute("href") || "";
                var route = href.indexOf(ctx) === 0 ? href.slice(ctx.length) : href;
                route = route.split("?")[0].split("#")[0];
                if (route && route.charAt(0) === "/" && access.nav.indexOf(route) === -1) {
                    link.hidden = true;
                    link.style.display = "none";
                    link.setAttribute("aria-disabled", "true");
                }
            });
        }

        if (readSet) {
            document.querySelectorAll("a[href]").forEach(function (link) {
                if (link.classList.contains("brand") || link.classList.contains("logo") || link.classList.contains("btn-logout")) {
                    return;
                }
                var href = link.getAttribute("href") || "";
                if (!href || href.charAt(0) === "#" || href.indexOf("javascript:") === 0) {
                    return;
                }
                var route = href.indexOf(ctx) === 0 ? href.slice(ctx.length) : href;
                route = route.split("?")[0].split("#")[0];
                if (route && route.charAt(0) === "/" && route !== "/index.jsp" && route !== "/logout" && readSet.indexOf(route) === -1) {
                    link.hidden = true;
                    link.style.display = "none";
                    link.setAttribute("aria-disabled", "true");
                }
            });
        }
    }

    function showFlashToast() {
        var flash = window.SI_FLASH;
        if (!flash || (!flash.success && !flash.error)) return;
        var msg = flash.error || flash.success;
        var box = document.getElementById("toastBox");
        if (box) {
            var el = document.createElement("div");
            el.className = "toast" + (flash.error ? " warn" : " good");
            el.textContent = msg;
            box.appendChild(el);
            setTimeout(function () { el.remove(); }, 3500);
        }
    }

    function renderNotifications() {
        if (!alertCenter || !bellBadge || !alertList) return;
        var alerts = alertCenter.getAll();
        var unread = alerts.filter(function (alert) { return alert.unread; });
        bellBadge.textContent = unread.length > 99 ? "99+" : String(unread.length);
        bellBadge.hidden = unread.length === 0;
        if (!unread.length) {
            alertList.innerHTML = '<div class="alert-item"><span class="alert-dot"></span><div><strong>You are all caught up</strong><p>No unread alerts.</p></div></div>';
            return;
        }
        var canOpenAlerts = window.SI_CAN.read("/alerts");
        alertList.innerHTML = unread.slice(0, 4).map(function (alert) {
            var minutes = alert.minutesAgo;
            var age = minutes < 60 ? minutes + " min ago" : Math.floor(minutes / 60) + " h ago";
            var inner = '<span class="alert-dot"></span><div><strong>' + escapeHtml(alert.title) + '</strong><p>' + escapeHtml(age + " · " + window.IrrigationZones.name(alert.zoneId)) + '</p></div>';
            if (!canOpenAlerts) {
                return '<div class="alert-item ' + (alert.severity === "critical" ? "warn" : "") + '">' + inner + '</div>';
            }
            return '<a class="alert-item ' + (alert.severity === "critical" ? "warn" : "") + '" href="' + ctx + '/alerts">' + inner + '</a>';
        }).join("");
    }

    if (navToggle && mainNav) {
        navToggle.addEventListener("click", function () {
            var open = document.body.classList.toggle("nav-open");
            navToggle.setAttribute("aria-expanded", String(open));
        });
        mainNav.querySelectorAll("a").forEach(function (link) {
            link.addEventListener("click", function () {
                document.body.classList.remove("nav-open");
                navToggle.setAttribute("aria-expanded", "false");
            });
        });
        window.addEventListener("resize", function () {
            if (window.innerWidth > 1200) {
                document.body.classList.remove("nav-open");
                navToggle.setAttribute("aria-expanded", "false");
            }
        });
    }

    if (bellButton && alertMenu) {
        bellButton.addEventListener("click", function () {
            var open = alertMenu.hidden;
            alertMenu.hidden = !open;
            bellButton.setAttribute("aria-expanded", String(open));
        });
        document.addEventListener("click", function (event) {
            if (!event.target.closest(".bell-wrap") && !alertMenu.hidden) {
                alertMenu.hidden = true;
                bellButton.setAttribute("aria-expanded", "false");
            }
        });
        document.addEventListener("keydown", function (event) {
            if (event.key === "Escape") {
                alertMenu.hidden = true;
                bellButton.setAttribute("aria-expanded", "false");
            }
        });
    }

    applyUserAndAccess();
    renderNotifications();
    showFlashToast();
    window.addEventListener("storage", function (event) {
        if (event.key === "si.alerts.read.v1") renderNotifications();
    });
    window.addEventListener("si:alerts-updated", renderNotifications);
}());
