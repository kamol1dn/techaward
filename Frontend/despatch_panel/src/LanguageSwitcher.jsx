// src/components/LanguageSelect.jsx
import React from 'react';
import { useTranslation } from 'react-i18next';

const LanguageSelect = () => {
  const { i18n } = useTranslation();

  const handleChange = (e) => {
    i18n.changeLanguage(e.target.value);
  };

  return (
    <select
      value={i18n.language}
      onChange={handleChange}
      className="px-2 py-1 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
    >
      <option value="en">English</option>
      <option value="uz">O'zbek</option>
      <option value="ru">Русский</option>
    </select>
  );
};

export default LanguageSelect;
