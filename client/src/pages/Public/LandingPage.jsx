import React from 'react';
import { Link } from 'react-router-dom';
import './LandingPage.css';

export default function LandingPage() {
  return (
    <section className="landing">
      <h1>AgroMarket Directo</h1>
      <p>Bienvenido a la plataforma de venta directa para agricultores.</p>
      <nav>
        <Link to="/login" className="btn">Iniciar sesión</Link>
        <Link to="/register" className="btn">Registrarse</Link>
        <Link to="/catalog" className="btn">Ver catálogo</Link>
      </nav>
    </section>
  );
}
