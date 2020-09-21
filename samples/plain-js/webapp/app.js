const keycloakUrl = "http://localhost:8180/auth"

const script = document.createElement('script');
script.type = 'text/javascript';
script.src = keycloakUrl + "/js/keycloak.js";
document.getElementsByTagName('head')[0].appendChild(script);

function notAuthenticated() {
  document.getElementById('not-authenticated').style.display = 'block';
  document.getElementById('message').innerHTML = 'Hello, World!'
}

function authenticated() {
  const name = keycloak.tokenParsed['given_name'] + ' ' +
    keycloak.tokenParsed['family_name'];
  document.getElementById('authenticated').style.display = 'block';
  document.getElementById('message').innerHTML = `Hello, ${name}!`;
}

window.onload = () => {
  window.keycloak = new Keycloak({
    url: keycloakUrl,
    realm: 'demo',
    clientId: 'plain-js'
  });
  keycloak.init({
    onLoad: 'check-sso',
    checkLoginIframeInterval: 1
  }).success(() => {
    if (keycloak.authenticated)
      authenticated();
    else
      notAuthenticated();
    document.body.style.display = 'block';
  });
  keycloak.onAuthLogout = notAuthenticated;
}
