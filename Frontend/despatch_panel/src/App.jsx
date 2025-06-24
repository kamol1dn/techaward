import React, { useState, useEffect } from 'react';
import { AlertTriangle, Search, Filter, MapPin, User, Phone, Mail, Clock, ExternalLink, Edit2, Save, X, Info } from 'lucide-react';
import './i18n.js';
import { useTranslation } from 'react-i18next';
import LanguageSwitcher from './LanguageSwitcher';


// API configuration
const API_BASE_URL = 'http://127.0.0.1:8000/api';

// Auth context for managing login state
const AuthContext = React.createContext();

// Login Component
const LoginPage = ({ onLogin }) => {
  const { t, i18n } = useTranslation();

  const [formData, setFormData] = useState({
    username: '',
    password: '',
    role: 'dispatcher'
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async () => {
    if (!formData.username || !formData.password) {
      setError(t('login_error_required'));
      return;
    }

    setLoading(true); 
    setError('');

    // Static login for demo
    if (formData.username === 'Bekhruz' && formData.password === '1234') {
      const userData = {
        username: 'Bekhruz',
        role: formData.role,
        id: 1,
      };
      // For demo purposes, we'll store a dummy token
      const dummyToken = 'demo_token_' + Date.now();
      setAccessToken(dummyToken);
      setUserData(userData);
      onLogin(userData);
      setLoading(false);
      return;
    }

    try {
      const response = await fetch(`${API_BASE_URL}/auth/login`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          username: formData.username,
          password: formData.password,
          role: formData.role
        }),
      });

      if (response.ok) {
        const data = await response.json();
        
        // Store both tokens with consistent naming
        if (data.access) {
          setAccessToken(data.access);
        }
        if (data.refresh) {
          setRefreshToken(data.refresh);
        }
        
        // Use the user data returned from the API
        const userData = {
          username: data.username,
          role: data.role,
          id: data.id,
        };
        
        setUserData(userData);
        onLogin(userData);
      } else {
        const errorData = await response.json();
        setError(errorData.error || errorData.message || t('login_error_invalid'));
      }
    } catch (error) {
      console.error('Login error:', error);
      setError(t('login_error_network'));
    } finally {
      setLoading(false);
    }
  };

  // ADD THIS FUNCTION HERE
  const handleKeyDown = (e) => {
    if (e.key === 'Enter') {
      handleSubmit();
    }
  };

  return (

    <div className="h-screen bg-gray-800 relative">
  {/* 🌐 Language switcher in top-right corner */}
  <div className="absolute top-4 right-4 z-50">
    <LanguageSwitcher />
  </div>

  {/* Centered login form */}
  <div className="flex items-center justify-center h-full">
    <div className="bg-white p-8 rounded-lg shadow-lg w-96">
      <div className="text-center mb-6">
        <AlertTriangle className="mx-auto text-red-500 mb-2" size={48} />
        <h1 className="text-2xl font-bold text-gray-800">{t('login_title')}</h1>
        <p className="text-gray-600">{t('login_subtitle')}</p>
      </div>

      <div>
        <div className="mb-4">
          <label className="block text-gray-700 text-sm font-medium mb-2">
            {t('login_username')}
          </label>
          <input
            type="text"
            placeholder={t('login_place')}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-500"
            value={formData.username}
            onChange={(e) => setFormData({ ...formData, username: e.target.value })}
            onKeyDown={handleKeyDown}
          />
        </div>

        <div className="mb-4">
          <label className="block text-gray-700 text-sm font-medium mb-2">
            {t('login_password')}
          </label>
          <input
            type="password"
            placeholder={t('login_password_place')}
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-500"
            value={formData.password}
            onChange={(e) => setFormData({ ...formData, password: e.target.value })}
            onKeyDown={handleKeyDown}
          />
        </div>

        <div className="mb-6">
          <label className="block text-gray-700 text-sm font-medium mb-2">
            {t('login_role')}
          </label>
          <select
            className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-500"
            value={formData.role}
            onChange={(e) => setFormData({ ...formData, role: e.target.value })}
            onKeyDown={handleKeyDown}
          >
            <option value="dispatcher">{t('login_dispatcher')}</option>
            <option value="responder">{t('login_responder')}</option>
          </select>
        </div>

        {error && (
          <div className="mb-4 p-2 bg-red-100 border border-red-400 text-red-700 rounded">
            {error}
          </div>
        )}

        <button
          onClick={handleSubmit}
          disabled={loading}
          className="w-full bg-red-500 text-white py-2 px-4 rounded-md hover:bg-red-600 focus:outline-none focus:ring-2 focus:ring-red-500 disabled:opacity-50"
        >
          {loading ? t('login_loading') : t('login_button')}
        </button>
      </div>
    </div>
  </div>
</div>

  );
};

// User Data Modal
const UserDataModal = ({ userData, onClose }) => {
    const { t, i18n } = useTranslation();

    if (!userData) return null;

    // Check if no user data available
    if (userData.noData) {
      return (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
          <div className="bg-white rounded-lg p-6 w-96">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-xl font-bold">{t('emergency_user_info')}</h2>
              <button
                onClick={onClose}
                className="text-red-500 hover:text-red-700 font-semibold"
              >
                X
              </button>
            </div>
            <div className="text-center text-gray-500 py-4">
              {t('modal_no_user_data')}
            </div>
          </div>
        </div>
      );
    }
    
    // Helper function to check if a field has valid data
    const hasValidData = (value) => {
      return value && value !== null && value !== undefined && value !== '' && value.toLowerCase() !== 'none';
    };

    // Helper function to display field or "No info"
    const displayField = (value) => {
      return hasValidData(value) ? value : t('modal_no_info');
    };

    return (
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-lg p-6 w-96 max-h-96 overflow-y-auto">
          <div className="flex justify-between items-center mb-4">
            <h2 className="text-xl font-bold">{t('emergency_user_info')}</h2>
            <button
              onClick={onClose}
              className="text-red-500 hover:text-red-700 font-semibold"
            >
              X
            </button>
          </div>
          <div className="space-y-2">
            <div><strong>{t('modal_name')}:</strong> {displayField(userData.name)} {displayField(userData.surname)}</div>
            <div><strong>{t('modal_phone')}:</strong> {displayField(userData.phone)}</div>
            <div><strong>{t('modal_email')}:</strong> {displayField(userData.email)}</div>
            <div><strong>{t('age')}:</strong> {displayField(userData.age)}</div>
            <div><strong>{t('gender')}:</strong> {displayField(userData.gender)}</div>
            <div><strong>{t('passport')}:</strong> {displayField(userData.passport)}</div>
            <div><strong>{t('modal_blood_type')}:</strong> {displayField(userData.blood_type)}</div>
            <div><strong>{t('modal_allergies')}:</strong> {displayField(userData.allergies)}</div>
            <div><strong>{t('modal_illness')}:</strong> {displayField(userData.illness)}</div>
            <div><strong>{t('modal_additional_info')}:</strong> {displayField(userData.additional_info)}</div>
          </div>
        </div>
      </div>
    );
 };

// Emergency Card Component
const EmergencyCard = ({ emergency, user, onStatusUpdate, onShowUser, onAssignmentUpdate }) => {
  const { t, i18n } = useTranslation();

  // Add this function in EmergencyCard component
 const shouldShowStatusButton = () => {
  if (user.role === 'dispatcher') {
    return emergency.status === 'pending';
  } else if (user.role === 'responder') {
    return emergency.status === 'in_progress';
  }
  return false;
 };

 const getTranslatedStatus = (status) => {
    switch (status) {
      case 'pending': return t('filter_pending');
      case 'in_progress': return t('filter_in_progress');
      case 'resolved': return t('filter_resolved');
      case 'done': return t('filter_resolved'); // fallback for old status
      default: return status;
    }
 };

  const [updating, setUpdating] = useState(false);
  const [isEditingAssignment, setIsEditingAssignment] = useState(false);
  const [assignmentValue, setAssignmentValue] = useState(emergency.assigned_to || '');
  const [error, setError] = useState('');

  const getStatusColor = (status) => {
    switch (status) {
      case 'pending': return 'bg-yellow-100 text-yellow-800';
      case 'in_progress': return 'bg-blue-100 text-blue-800';
      case 'resolved': return 'bg-green-100 text-green-800';
      case 'done': return 'bg-green-100 text-green-800'; // fallback for old status
      default: return 'bg-gray-100 text-gray-800';
    }
  };

 const getNextStatus = (currentStatus, userRole) => {
  if (userRole === 'dispatcher') {
    // Dispatcher can only move from pending to in_progress
    if (currentStatus === 'pending') return 'in_progress';
    return currentStatus; // No change for other statuses
  } else if (userRole === 'responder') {
    // Responder can only move from in_progress to resolved
    if (currentStatus === 'in_progress') return 'resolved';
    return currentStatus; // No change for other statuses
  }
  return currentStatus;
 };

 const getStatusButtonText = (status, userRole) => {
  if (userRole === 'dispatcher') {
    if (status === 'pending') return 'Start';
    return t('emergency_cannot_update'); // For non-pending status
  } else if (userRole === 'responder') {
    if (status === 'in_progress') return 'Complete';
    return t('emergency_cannot_update'); // For non-in_progress status
  }
  return t('emergency_completed');
 };

 const handleStatusUpdate = async () => {
  setError('');
  
  const userRole = user.role;
  
  // Check role-based permissions
  if (userRole === 'dispatcher' && emergency.status !== 'pending') {
    setError(t('emergency_error_dispatcher_permission'));
    return;
  }
  
  if (userRole === 'responder' && emergency.status !== 'in_progress') {
    setError(t('emergency_error_responder_permission'));
    return;
  }
  
  // Check if trying to start service without assignment (dispatcher only)
  if (userRole === 'dispatcher' && emergency.status === 'pending' && (!emergency.assigned_to || emergency.assigned_to.trim() === '')) {
    setError(t('emergency_error_assignment_required'));
    return;
  }
  
  setUpdating(true);
  const nextStatus = getNextStatus(emergency.status, userRole);
  
  try {
    const token = getAccessToken();
    
    if (!token) {
      setError(t('emergency_error_token'));
      setUpdating(false);
      return;
    }

    const requestBody = {
      status: nextStatus,
      assigned_to: emergency.assigned_to || null
    };

    const response = await fetch(`${API_BASE_URL}/request/assign/${emergency.id}/`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
      body: JSON.stringify(requestBody),
    });

    if (response.ok) {
      const responseData = await response.json();
      onStatusUpdate(emergency.id, nextStatus);
      setError('');
    } else {
      const errorData = await response.json();
      let errorMessage = t('emergency_error_status_failed');
      if (errorData.message) {
        errorMessage = errorData.message;
      }
      if (errorData.errors) {
        errorMessage += ': ' + JSON.stringify(errorData.errors);
      }
      setError(errorMessage);
    }
  } catch (error) {
    setError(`Network error: ${error.message}`);
  } finally {
    setUpdating(false);
  }
 };

 const handleAssignmentSave = async () => {
  // ADDED: Check if user is dispatcher before allowing assignment
  if (user.role !== 'dispatcher') {
    setError(t('emergency_error_assignment_permission'));
    return;
  }

  // ADDED: Check if emergency is still pending
  if (emergency.status !== 'pending') {
    setError(t('emergency_error_assignment_status'));
    return;
  }

  setUpdating(true);
  setError('');
  
  try {
    const token = getAccessToken();
    
    if (!token) {
      setError(t('emergency_error_token'));
      setUpdating(false);
      return;
    }

    const requestBody = {
      assigned_to: assignmentValue,
      status: emergency.status
    };

    const response = await fetch(`${API_BASE_URL}/request/assign/${emergency.id}/`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
      body: JSON.stringify(requestBody),
    });

    if (response.ok) {
      const responseData = await response.json();
      onAssignmentUpdate(emergency.id, assignmentValue);
      setIsEditingAssignment(false);
      setError('');
    } else {
      const errorData = await response.json();
      let errorMessage = t('emergency_error_assignment_failed');
      if (errorData.message) {
        errorMessage = errorData.message;
      }
      setError(errorMessage);
    }
  } catch (error) {
    setError(`Network error: ${error.message}`);
  } finally {
    setUpdating(false);
  }
};

  const handleAssignmentCancel = () => {
    setAssignmentValue(emergency.assigned_to || '');
    setIsEditingAssignment(false);
    setError('');
  };

  const isCompleted = emergency.status === 'resolved' || emergency.status === 'done';
  // ADDED: Check if user can edit assignments (only dispatchers)
  const canEditAssignment = user.role === 'dispatcher' && emergency.status === 'pending';

  return (
    <div className="bg-white border rounded-lg p-4 shadow-sm">
      <div className="flex justify-between items-start mb-3">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="font-semibold text-lg">#{emergency.id}</span>
            <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(emergency.status)}`}>
               {getTranslatedStatus(emergency.status)}
            </span>
          </div>
          <div className="text-sm text-gray-600">
            <div className="flex items-center gap-1 mb-1">
              <AlertTriangle size={14} />
              {emergency.type}
            </div>
            <div className="flex items-center gap-1 mb-1">
              <Clock size={14} />
              {new Date(emergency.date_created).toLocaleString()}
            </div>
            <div className="flex items-center gap-1 mb-1">
              <MapPin size={14} />
              {emergency.location_info || t('location_not_provided')}
            </div>
            <div className="flex items-center gap-1 mb-1">
              <AlertTriangle size={14} />
              <span className="font-medium">{t('emergency_extra_info')}:</span>
              <span className="text-gray-700">
                {emergency.extra_info || t('emergency_no_info')}
              </span>
            </div>
            
            {/* Assigned To Section */}
            <div className="flex items-center gap-1 mt-2">
              <User size={14} />
              <span className="font-medium">{t('emergency_assigned_to')}:</span>
              {isEditingAssignment ? (
                <div className="flex items-center gap-1 ml-1">
                  <input
                    type="text"
                    value={assignmentValue}
                    onChange={(e) => setAssignmentValue(e.target.value)}
                    placeholder={t('emergency_assign_place')}
                    className="px-2 py-1 text-xs border border-gray-300 rounded focus:outline-none focus:ring-1 focus:ring-blue-500"
                    style={{ minWidth: '120px' }}
                    autoFocus
                    autoComplete="off"
                    autoCorrect="off"
                    autoCapitalize="off"
                    spellCheck="false"
                    name="staff-assignment"
                    id={`assignment-${emergency.id}`}
                    aria-label="Assign staff member"
                    onFocus={(e) => {
                      e.target.select();
                      // Ensure this input stays focused
                      setTimeout(() => e.target.focus(), 0);
                    }}
                    onBlur={(e) => {
                      // Prevent losing focus unless clicking save/cancel buttons
                      const relatedTarget = e.relatedTarget;
                      if (relatedTarget && (relatedTarget.closest('[title="Save"]') || relatedTarget.closest('[title="Cancel"]'))) {
                        return;
                      }
                      // Refocus after a short delay if no save/cancel was clicked
                      setTimeout(() => {
                        if (isEditingAssignment) {
                          e.target.focus();
                        }
                      }, 100);
                    }}
                  />
                  <button
                    onClick={handleAssignmentSave}
                    disabled={updating}
                    className="p-1 text-green-600 hover:text-green-800 disabled:opacity-50"
                    title={t('emergency_save')}
                  >
                    <Save size={12} />
                  </button>
                  <button
                    onClick={handleAssignmentCancel}
                    className="p-1 text-red-600 hover:text-red-800"
                    title={t('emergency_cancel')}
                  >
                    <X size={12} />
                  </button>
                </div>
              ) : (
                <div className="flex items-center gap-1 ml-1">
                  <span className="text-gray-800">
                    {emergency.assigned_to || t('emergency_unassigned')}
                  </span>
                  {/* CHANGED: Use canEditAssignment instead of !isCompleted */}
                  {canEditAssignment && (
                    <button
                      onClick={() => setIsEditingAssignment(true)}
                      className="p-1 text-blue-600 hover:text-blue-800"
                      title={t('emergency_edit_assignment')}
                    >
                      <Edit2 size={12} />
                    </button>
                  )}
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Error message */}
      {error && (
        <div className="mb-3 p-2 bg-red-100 border border-red-400 text-red-700 rounded text-sm">
          {error}
        </div>
      )}

      <div className="flex gap-2 flex-wrap">
        {((user.role === 'dispatcher' && emergency.status === 'pending') || 
        (user.role === 'responder' && emergency.status === 'in_progress')) && (
        <button
          onClick={handleStatusUpdate}
          disabled={updating}
          className="px-3 py-1 bg-blue-500 text-white rounded text-sm hover:bg-blue-600 disabled:opacity-50"
        >
          {updating ? 'Updating...' : getStatusButtonText(emergency.status, user.role)}
        </button>
        )}
        
        <button
          onClick={() => onShowUser(emergency)}
          className="px-3 py-1 bg-green-500 text-white rounded text-sm hover:bg-green-600 flex items-center gap-1"
        >
          <User size={14} />
          {t('emergency_user_info')}
        </button>
        
        <a
          href={`https://www.google.com/maps?q=${emergency.latitude},${emergency.longitude}`}
          target="_blank"
          rel="noopener noreferrer"
          className="px-3 py-1 bg-red-500 text-white rounded text-sm hover:bg-red-600 flex items-center gap-1"
        >
          <ExternalLink size={14} />
          {t('emergency_directions')}
        </a>
      </div>
    </div>
  );
};

// Storage helper functions - using sessionStorage as fallback, then in-memory
let accessToken = null;
let refreshToken = null;
let userData = null;

// Initialize from sessionStorage if available
try {
  if (typeof window !== 'undefined' && window.sessionStorage) {
    accessToken = sessionStorage.getItem('accessToken');
    refreshToken = sessionStorage.getItem('refreshToken');
    const storedUserData = sessionStorage.getItem('userData');
    if (storedUserData) {
      userData = JSON.parse(storedUserData);
    }
  }
} catch (e) {
  // Fallback to in-memory storage if sessionStorage fails
  console.log('SessionStorage not available, using in-memory storage');
}

const setAccessToken = (token) => {
  accessToken = token;
  try {
    if (typeof window !== 'undefined' && window.sessionStorage) {
      if (token) {
        sessionStorage.setItem('accessToken', token);
      } else {
        sessionStorage.removeItem('accessToken');
      }
    }
  } catch (e) {
    // Continue with in-memory storage
  }
};

const getAccessToken = () => {
  return accessToken;
};

const setRefreshToken = (token) => {
  refreshToken = token;
  try {
    if (typeof window !== 'undefined' && window.sessionStorage) {
      if (token) {
        sessionStorage.setItem('refreshToken', token);
      } else {
        sessionStorage.removeItem('refreshToken');
      }
    }
  } catch (e) {
    // Continue with in-memory storage
  }
};

const getRefreshToken = () => {
  return refreshToken;
};

const setUserData = (data) => {
  userData = data;
  try {
    if (typeof window !== 'undefined' && window.sessionStorage) {
      if (data) {
        sessionStorage.setItem('userData', JSON.stringify(data));
      } else {
        sessionStorage.removeItem('userData');
      }
    }
  } catch (e) {
    // Continue with in-memory storage
  }
};

const getUserData = () => {
  return userData;
};

// Dashboard Component
const Dashboard = ({ user, onLogout }) => {
  const { t, i18n } = useTranslation();

    const handleHistoryUserShow = async (emergency) => {
  try {
    const token = getAccessToken();
    
    if (!token) {
      setError(t('emergency_error_token'));
      return;
    }

    const response = await fetch(`${API_BASE_URL}/request/emergency`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
    });

    if (response.ok) {
      const data = await response.json();
      // Find the specific emergency to get its user_data
      const emergencyData = data.request?.find(req => req.id === emergency.id);
      
      if (emergencyData && emergencyData.user_data) {
        setSelectedUser(emergencyData.user_data);
      } else {
        // Show modal with no user data message
        setSelectedUser({ noData: true });
      }
    } else {
      setError(t('emergency_error_user_fetch'));
    }
  } catch (error) {
    console.error('Error fetching user data:', error);
    setError(t('emergency_error_network'));
  }
};

  const getFilterOptions = () => {
    if (user.role === 'responder') {
      return [
        { label: t('filter_all'), value: 'all' },
        { label: t('filter_in_progress'), value: 'in_progress' },
        { label: t('filter_resolved'), value: 'resolved' }
      ];
    } else {
      return [
        { label: t('filter_all'), value: 'all' },
        { label: t('filter_pending'), value: 'pending' },
        { label: t('filter_in_progress'), value: 'in_progress' },
        { label: t('filter_resolved'), value: 'resolved' }
      ];
    }
  }; 

  const sortEmergenciesByLatest = (emergencies) => {
   return [...emergencies].sort((a, b) => {
    // Convert date strings to Date objects for proper comparison
    const dateA = new Date(a.date_created);
    const dateB = new Date(b.date_created);
    
    // Sort in descending order (latest first)
    return dateB.getTime() - dateA.getTime();
  });
 
  };

  const [emergencies, setEmergencies] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('all');
  const [search, setSearch] = useState('');
  const [selectedUser, setSelectedUser] = useState(null);
  const [currentPage, setCurrentPage] = useState('dashboard');
  const [error, setError] = useState('');

  useEffect(() => {
    fetchEmergencies();
  }, [user]);

 const fetchEmergencies = async (statusFilter = null) => {
  setLoading(true);
  setError('');
  try {
    const token = getAccessToken();
    
    if (!token) {
      setError(t('emergency_error_token'));
      onLogout();
      return;
    }

    const response = await fetch(`${API_BASE_URL}/request/emergency`, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
    });

    if (response.ok) {
      const data = await response.json();
      let emergencyData = data.request || data || [];

      if (!Array.isArray(emergencyData)) emergencyData = [];

      // Filter by role FIRST, before status filtering
      if (user.role === 'responder') {
        emergencyData = emergencyData.filter(
          emergency => emergency.assigned_to === user.username
        );
      }

      // Then apply status filter if provided
      if (statusFilter) {
        emergencyData = emergencyData.filter(
          (emergency) => emergency.status === statusFilter
        );
      }

      setEmergencies(emergencyData);
    } else {
      const errorText = await response.text();
      if (response.status === 401) {
        onLogout();
      } else {
        setError(`Failed to fetch emergencies: ${response.status} ${response.statusText}`);
        setEmergencies([]);
      }
    }
  } catch (error) {
    setError(`Network error: ${error.message}`);
    setEmergencies([]);
  } finally {
    setLoading(false);
  }
 };

  const handleStatusUpdate = (id, newStatus) => {
    setEmergencies((prev) =>
      prev.map((emergency) =>
        emergency.id === id ? { ...emergency, status: newStatus } : emergency
      )
    );
  };

  const handleAssignmentUpdate = (id, assignedTo) => {
    setEmergencies((prev) =>
      prev.map((emergency) =>
        emergency.id === id ? { ...emergency, assigned_to: assignedTo } : emergency
      )
    );
  };

  const handleShowUser = async (emergency) => {
    try {
      const token = getAccessToken();
      
      if (!token) {
        setError(t('emergency_error_token'));
        return;
      }

      const response = await fetch(`${API_BASE_URL}/request/emergency`, {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`,
        },
      });

      if (response.ok) {
        const data = await response.json();
        // Find the specific emergency to get its user_data
        const emergencyData = data.request?.find(req => req.id === emergency.id);
        
        if (emergencyData && emergencyData.user_data) {
          setSelectedUser(emergencyData.user_data);
        } else {
          // Show modal with no user data message
          setSelectedUser({ noData: true });
        }
      } else {
        setError(t('emergency_error_user_fetch'));
      }
    } catch (error) {
      console.error('Error fetching user data:', error);
      setError(t('emergency_error_network'));
    }
 };

  const filteredEmergencies = sortEmergenciesByLatest(
    emergencies.filter((emergency) => {
      const matchesFilter =
        filter === 'all' ||
        emergency.status === filter ||
        (filter === 'resolved' && (emergency.status === 'resolved' || emergency.status === 'done'));

      const matchesSearch =
        search === '' ||
        emergency.type.toLowerCase().includes(search.toLowerCase()) ||
        emergency.id.toString().includes(search) ||
        (emergency.location_info || '').toLowerCase().includes(search.toLowerCase()) ||
        (emergency.assigned_to || '').toLowerCase().includes(search.toLowerCase());

      return matchesFilter && matchesSearch;
    })
  );

 const resolvedEmergencies = sortEmergenciesByLatest(
    emergencies.filter(
      (emergency) =>
        emergency.status === 'resolved' || emergency.status === 'done'
    )
  );

  // ----- HISTORY PAGE -----
  if (currentPage === 'history') {
    return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white border-b px-6 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-4">
            <button
              onClick={() => setCurrentPage('dashboard')}
              className="text-gray-600 hover:text-gray-800"
            >
              {t('history_back')}
            </button>
            <h1 className="text-xl font-bold">{t('history_title')}</h1>
          </div>
        </div>
      </header>

      <div className="p-6">
        <div className="bg-white rounded-lg shadow">
          <div className="p-4 border-b">
            <div className="grid grid-cols-6 gap-4 font-medium text-gray-700">
              <div>{t('emergency_id')}</div>
              <div>{t('emergency_type')}</div>
              <div>{t('emergency_user_info')}</div>
              <div>{t('emergency_status')}</div>
              <div>{t('emergency_date')}</div>
              <div>{t('emergency_assigned_to')}</div>
            </div>
          </div>

          <div className="p-4 divide-y">
            {resolvedEmergencies.length === 0 ? (
              <div className="text-center text-gray-500 py-6">{t('history_no_items')}</div>
            ) : (
              resolvedEmergencies.map((emergency) => (
                <div
                  key={emergency.id}
                  className="grid grid-cols-6 gap-4 py-3 text-sm text-gray-800"
                >
                  <div>{emergency.id}</div>
                  <div>{emergency.type}</div>
                  <div>
                    <button
                      onClick={() => handleHistoryUserShow(emergency)}
                      className="flex items-center gap-1 text-blue-600 hover:text-blue-800 bg-blue-50 hover:bg-blue-100 px-2 py-1 rounded text-xs"
                    >
                      <Info size={12} />
                      {t('history_user_ifo')}
                    </button>
                  </div>
                  <div className="capitalize">{emergency.status}</div>
                  <div>{new Date(emergency.date_created).toLocaleString()}</div>
                  <div>{emergency.assigned_to || 'Unassigned'}</div>
                </div>
              ))
            )}
          </div>
        </div>
      </div>

      {/* Add the modal for history user data */}
      {selectedUser && (
        <UserDataModal
          userData={selectedUser}
          onClose={() => setSelectedUser(null)}
        />
      )}
    </div>
  );
  }

  // ----- MAIN DASHBOARD PAGE -----
  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white border-b px-6 py-4">
        <div className="flex items-center justify-between">
          <div className="flex items-center gap-2">
            <AlertTriangle className="text-red-500" size={24} />
            <span className="text-xl font-bold">{t('dashboard_title')}</span>
          </div>
          <div className="flex items-center gap-4">
            <span className="text-gray-600">{t('welcome_user')} {user?.username} ({user?.role})</span>
            <LanguageSwitcher />
            <button
              onClick={() => setCurrentPage('history')}
              className="text-blue-600 hover:text-blue-800"
            >
              {t('dashboard_history')}
            </button>
            <button
              onClick={onLogout}
              className="text-red-600 hover:text-red-800"
            >
              {t('dashboard_logout')}
            </button>
          </div>
        </div>
      </header>

      <div className="p-6">
        <div className="flex gap-4 mb-6">
          <div className="flex items-center gap-2">
            <Filter size={20} />
           <select
              value={filter}
              onChange={(e) => setFilter(e.target.value)}
              className="px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            >
              {getFilterOptions().map(option => (
                <option key={option.value} value={option.value}>{option.label}</option>
              ))}
            </select>
          </div>

          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={20} />
            <input
              type="text"
              placeholder={t('dashboard_search_placeholder')}
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              onPaste={(e) => {
                // Only allow paste if this input is actually focused
                if (document.activeElement !== e.target) {
                e.preventDefault();
                }
                 }}
              className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-500"
            />
          </div>
        </div>

        {loading ? (
          <div className="text-center py-8">{t('dashboard_loading')}</div>
        ) : filteredEmergencies.length === 0 ? (
          <div className="text-center py-8 text-gray-500">
            {t('dashboard_no_results')}
          </div>
        ) : (
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            {filteredEmergencies.map((emergency) => (
              <EmergencyCard
                key={emergency.id}
                emergency={emergency}
                user={user}
                onStatusUpdate={handleStatusUpdate}
                onShowUser={handleShowUser}
                onAssignmentUpdate={handleAssignmentUpdate}
              />
            ))}
          </div>
        )}
      </div>

      {selectedUser && (
        <UserDataModal
          userData={selectedUser}
          onClose={() => setSelectedUser(null)}
        />
      )}
    </div>
  );
};

// Main App Component
const App = () => {
  const { t } = useTranslation();
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Check if user is already logged in
    const token = getAccessToken();
    const storedUserData = getUserData();
    
    if (token && storedUserData) {
      setUser(storedUserData);
    }
    setLoading(false);
  }, []);

  const handleLogin = (userData) => {
    setUser(userData);
    setUserData(userData);
  };

//  logout function 

const handleLogout = async () => {
  try {
    const token = getAccessToken();
    
    // Call the logout API endpoint
    if (token && !token.startsWith('demo_token_')) {
      try {
        const response = await fetch(`${API_BASE_URL}/auth/logout`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`,
          },
          // Send refresh token if available
          body: JSON.stringify({
            refresh: getRefreshToken()
          }),
        });

        if (!response.ok) {
          console.error('Logout API call failed:', response.status, response.statusText);
          // Continue with local logout even if API call fails
        } else {
          console.log('Successfully logged out from server');
        }
      } catch (error) {
        console.error('Network error during logout:', error);
        // Continue with local logout even if network fails
      }
    }
  } catch (error) {
    console.error('Error during logout process:', error);
  } finally {
    // Always clear local storage and state regardless of API call result
    setAccessToken(null);
    setRefreshToken(null);
    setUserData(null);
    setUser(null);
    
    // Clear sessionStorage
    try {
      if (typeof window !== 'undefined' && window.sessionStorage) {
        sessionStorage.clear();
      }
    } catch (e) {
      // Continue without sessionStorage
    }
  }
};

  if (loading) {
    return (
      <div className="min-h-screen bg-gray-50 flex items-center justify-center">
        <div className="text-center">{t('app_loading')}</div>
      </div>
    );
  }

  return (
    <AuthContext.Provider value={{ user, handleLogin, handleLogout }}>
      {user ? (
        <Dashboard user={user} onLogout={handleLogout} />
      ) : (
        <LoginPage onLogin={handleLogin} />
      )}
    </AuthContext.Provider>
  );
};

export default App;