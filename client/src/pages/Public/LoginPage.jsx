import React from 'react';
import { Link } from 'react-router-dom';
import './LoginPage.css';

export default function LoginPage() {
  return (
    <section className="login">
      <h1>Iniciar Sesión</h1>
      <p>Este es un placeholder de la página de login.</p>
      <Link to="/" className="btn">Volver</Link>
    </section>
  );
}
