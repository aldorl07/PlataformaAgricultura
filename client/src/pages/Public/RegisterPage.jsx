import React from 'react';
import { Link } from 'react-router-dom';
import './RegisterPage.css';

export default function RegisterPage() {
  return (
    <section className="register">
      <h1>Registrarse</h1>
      <p>Este es un placeholder de la página de registro.</p>
      <Link to="/" className="btn">Volver</Link>
    </section>
  );
}
