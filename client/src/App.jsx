import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import LandingPage from './pages/Public/LandingPage';
import LoginPage from './pages/Public/LoginPage';
import RegisterPage from './pages/Public/RegisterPage';
import CatalogPage from './pages/Catalog/CatalogPage';
import QuoteSimulator from './pages/Quote/QuoteSimulator';
import FarmerDashboard from './pages/Farmer/FarmerDashboard';
import AdminDashboard from './pages/Admin/AdminDashboard';

export default function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<LandingPage />} />
        <Route path="/login" element={<LoginPage />} />
        <Route path="/register" element={<RegisterPage />} />
        <Route path="/catalog" element={<CatalogPage />} />
        <Route path="/quote" element={<QuoteSimulator />} />
        <Route path="/farmer" element={<FarmerDashboard />} />
        <Route path="/admin" element={<AdminDashboard />} />
      </Routes>
    </Router>
  );
}
