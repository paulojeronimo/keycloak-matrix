const keycloakUrl = "http://localhost:8080/auth"

const script = document.createElement('script');
script.type = 'text/javascript';
script.src = keycloakUrl + "/js/keycloak.js";
document.getElementsByTagName('head')[0].appendChild(script);

const serviceUrl = 'http://localhost:8080/service'

function notAuthenticated() {
    document.getElementById('not-authenticated').style.display = 'block';
    document.getElementById('authenticated').style.display = 'none';
}

function authenticated() {
    document.getElementById('not-authenticated').style.display = 'none';
    document.getElementById('authenticated').style.display = 'block';
    document.getElementById('message').innerHTML = 'User: ' + keycloak.tokenParsed['preferred_username'];
}

function request(endpoint) {
    var req = function() {
        var req = new XMLHttpRequest();
        var output = document.getElementById('message');
        req.open('GET', serviceUrl + '/' + endpoint, true);

        if (keycloak.authenticated) {
            req.setRequestHeader('Authorization', 'Bearer ' + keycloak.token);
        }

        req.onreadystatechange = function () {
            if (req.readyState == 4) {
                if (req.status == 200) {
                    output.innerHTML = 'Message: ' + JSON.parse(req.responseText).message;
                } else if (req.status == 0) {
                    output.innerHTML = '<span class="error">Request failed</span>';
                } else {
                    output.innerHTML = '<span class="error">' + req.status + ' ' + req.statusText + '</span>';
                }
            }
        };

        req.send();
    };

    if (keycloak.authenticated) {
        keycloak.updateToken(30).success(req);
    } else {
        req();
    }
}

window.onload = function () {
    window.keycloak = new Keycloak({
        url: keycloakUrl,
        realm: 'demo',
        clientId: 'plain-js'
      });

    keycloak.init({ onLoad: 'check-sso', checkLoginIframeInterval: 1 }).success(function () {
        if (keycloak.authenticated) {
            authenticated();
        } else {
            notAuthenticated();
        }

        document.body.style.display = 'block';
    });

    keycloak.onAuthLogout = notAuthenticated;
}
