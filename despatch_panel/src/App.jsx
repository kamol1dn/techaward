import React, { useState, useEffect } from 'react';
import { AlertTriangle, Search, Filter, MapPin, User, Phone, Mail, Clock, ExternalLink, Edit2, Save, X } from 'lucide-react';

// API configuration
const API_BASE_URL = 'http://127.0.0.1:8000/api';

// Auth context for managing login state
const AuthContext = React.createContext();

// Login Component
const LoginPage = ({ onLogin }) => {
  const [formData, setFormData] = useState({
    username: '',
    password: '',
    role: 'dispatcher'
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async () => {
    if (!formData.username || !formData.password) {
      setError('Please fill in all fields');
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
        setError(errorData.error || errorData.message || 'Login failed');
      }
    } catch (error) {
      console.error('Login error:', error);
      setError('Network error. Please try again.');
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
    <div className="min-h-screen bg-gray-800 flex items-center justify-center">
      <div className="bg-white p-8 rounded-lg shadow-lg w-96">
        <div className="text-center mb-6">
          <AlertTriangle className="mx-auto text-red-500 mb-2" size={48} />
          <h1 className="text-2xl font-bold text-gray-800">Emergency Dispatch</h1>
          <p className="text-gray-600">Secure Access Portal</p>
        </div>

        <div>
          <div className="mb-4">
            <label className="block text-gray-700 text-sm font-medium mb-2">
              Username
            </label>
            <input
              type="text"
              placeholder="Enter username"
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-500"
              value={formData.username}
              onChange={(e) => setFormData({...formData, username: e.target.value})}
              onKeyDown={handleKeyDown}
            />
          </div>

          <div className="mb-4">
            <label className="block text-gray-700 text-sm font-medium mb-2">
              Password
            </label>
            <input
              type="password"
              placeholder="Enter password"
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-500"
              value={formData.password}
              onChange={(e) => setFormData({...formData, password: e.target.value})}
              onKeyDown={handleKeyDown}
            />
          </div>

          <div className="mb-6">
            <label className="block text-gray-700 text-sm font-medium mb-2">
              Role
            </label>
            <select
              className="w-full px-3 py-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-red-500"
              value={formData.role}
              onChange={(e) => setFormData({...formData, role: e.target.value})}
              onKeyDown={handleKeyDown}
            >
              <option value="dispatcher">Dispatcher</option>
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
            {loading ? 'Logging in...' : 'Login'}
          </button>
        </div>
      </div>
    </div>
  );
};

// User Data Modal
const UserDataModal = ({ userData, onClose }) => {
  if (!userData) return null;

  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-lg p-6 w-96 max-h-96 overflow-y-auto">
        <div className="flex justify-between items-center mb-4">
          <h2 className="text-xl font-bold">User Information</h2>
          <button
            onClick={onClose}
            className="text-gray-500 hover:text-gray-700"
          >
            ×
          </button>
        </div>
        <div className="space-y-2">
          <div><strong>Name:</strong> {userData.name} {userData.surname}</div>
          <div><strong>Phone:</strong> {userData.phone}</div>
          <div><strong>Email:</strong> {userData.email}</div>
          <div><strong>Age:</strong> {userData.age}</div>
          <div><strong>Gender:</strong> {userData.gender}</div>
          <div><strong>Passport:</strong> {userData.passport}</div>
          <div><strong>Blood Type:</strong> {userData.blood_type}</div>
          <div><strong>Allergies:</strong> {userData.allergies}</div>
          <div><strong>Illness:</strong> {userData.illness}</div>
          <div><strong>Additional Info:</strong> {userData.additional_info}</div>
        </div>
      </div>
    </div>
  );
};

// Emergency Card Component
const EmergencyCard = ({ emergency, onStatusUpdate, onShowUser, onAssignmentUpdate }) => {
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

  const getNextStatus = (currentStatus) => {
    switch (currentStatus) {
      case 'pending': return 'in_progress';
      case 'in_progress': return 'resolved';
      default: return currentStatus;
    }
  };

  const getStatusButtonText = (status) => {
    switch (status) {
      case 'pending': return 'Start';
      case 'in_progress': return 'Complete';
      default: return 'Completed';
    }
  };

  const handleStatusUpdate = async () => {
  setError('');
  
  // Check if trying to start service without assignment
  if (emergency.status === 'pending' && (!emergency.assigned_to || emergency.assigned_to.trim() === '')) {
    setError('Please assign staff before starting the service');
    return;
  }
  
  setUpdating(true);
  const nextStatus = getNextStatus(emergency.status);
  
  try {
    const token = getAccessToken();
    
    // For demo/offline mode, just update locally
    if (!token || token.startsWith('demo_token_')) {
      console.log('Demo mode: updating status locally from', emergency.status, 'to', nextStatus);
      onStatusUpdate(emergency.id, nextStatus);
      setUpdating(false);
      return;
    }

    // Prepare request body that matches your Django backend expectations
    const requestBody = {
      status: nextStatus,
      assigned_to: emergency.assigned_to || null
    };

    console.log('Sending PATCH request to:', `${API_BASE_URL}/request/assign/${emergency.id}/`);
    console.log('Request body:', requestBody);
    console.log('Current emergency:', emergency);

    const response = await fetch(`${API_BASE_URL}/request/assign/${emergency.id}/`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${token}`,
      },
      body: JSON.stringify(requestBody),
    });

    console.log('Response status:', response.status);

    if (response.ok) {
      const responseData = await response.json();
      console.log('Successfully updated status:', responseData);
      onStatusUpdate(emergency.id, nextStatus);
      setError('');
    } else {
      // Get detailed error information
      const errorData = await response.json();
      console.error('Failed to update status:', response.status, errorData);
      
      // Show detailed error message
      let errorMessage = 'Failed to update status';
      if (errorData.message) {
        errorMessage = errorData.message;
      }
      if (errorData.errors) {
        errorMessage += ': ' + JSON.stringify(errorData.errors);
      }
      
      setError(errorMessage);
    }
  } catch (error) {
    console.error('Network error updating status:', error);
    setError(`Network error: ${error.message}`);
  } finally {
    setUpdating(false);
  }
};

  const handleAssignmentSave = async () => {
  setUpdating(true);
  setError('');
  
  try {
    const token = getAccessToken();
    
    // For demo/offline mode, just update locally
    if (!token || token.startsWith('demo_token_')) {
      console.log('Demo mode: updating assignment locally');
      onAssignmentUpdate(emergency.id, assignmentValue);
      setIsEditingAssignment(false);
      setUpdating(false);
      return;
    }

    // Send only the fields that are changing
    const requestBody = {
      assigned_to: assignmentValue,
      status: emergency.status // Keep current status
    };

    console.log('Updating assignment for emergency:', emergency.id);
    console.log('Request body:', requestBody);

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
      console.log('Successfully updated assignment:', responseData);
      onAssignmentUpdate(emergency.id, assignmentValue);
      setIsEditingAssignment(false);
      setError('');
    } else {
      const errorData = await response.json();
      console.error('Failed to update assignment:', response.status, errorData);
      
      let errorMessage = 'Failed to update assignment';
      if (errorData.message) {
        errorMessage = errorData.message;
      }
      setError(errorMessage);
    }
  } catch (error) {
    console.error('Error updating assignment:', error);
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

  return (
    <div className="bg-white border rounded-lg p-4 shadow-sm">
      <div className="flex justify-between items-start mb-3">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="font-semibold text-lg">#{emergency.id}</span>
            <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(emergency.status)}`}>
              {emergency.status === 'resolved' ? 'resolved' : emergency.status.replace('_', ' ')}
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
              {emergency.location_info}
            </div>
            <div className="flex items-center gap-1 mb-1">
              <AlertTriangle size={14} />
              <span className="font-medium">Extra Info:</span>
              <span className="text-gray-700">
                {emergency.extra_info || 'No information'}
              </span>
            </div>
            
            {/* Assigned To Section */}
            <div className="flex items-center gap-1 mt-2">
              <User size={14} />
              <span className="font-medium">Assigned to:</span>
              {isEditingAssignment ? (
                <div className="flex items-center gap-1 ml-1">
                  <input
                    type="text"
                    value={assignmentValue}
                    onChange={(e) => setAssignmentValue(e.target.value)}
                    placeholder="Enter staff name"
                    className="px-2 py-1 text-xs border border-gray-300 rounded focus:outline-none focus:ring-1 focus:ring-blue-500"
                    style={{ minWidth: '120px' }}
                    autoFocus
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
                    title="Save"
                  >
                    <Save size={12} />
                  </button>
                  <button
                    onClick={handleAssignmentCancel}
                    className="p-1 text-red-600 hover:text-red-800"
                    title="Cancel"
                  >
                    <X size={12} />
                  </button>
                </div>
              ) : (
                <div className="flex items-center gap-1 ml-1">
                  <span className="text-gray-800">
                    {emergency.assigned_to || 'Unassigned'}
                  </span>
                  {!isCompleted && (
                    <button
                      onClick={() => setIsEditingAssignment(true)}
                      className="p-1 text-blue-600 hover:text-blue-800"
                      title="Edit assignment"
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
        {!isCompleted && (
          <button
            onClick={handleStatusUpdate}
            disabled={updating}
            className="px-3 py-1 bg-blue-500 text-white rounded text-sm hover:bg-blue-600 disabled:opacity-50"
          >
            {updating ? 'Updating...' : getStatusButtonText(emergency.status)}
          </button>
        )}
        
        <button
          onClick={() => onShowUser(emergency)}
          className="px-3 py-1 bg-green-500 text-white rounded text-sm hover:bg-green-600 flex items-center gap-1"
        >
          <User size={14} />
          User Info
        </button>
        
        <a
          href={`https://www.google.com/maps?q=${emergency.latitude},${emergency.longitude}`}
          target="_blank"
          rel="noopener noreferrer"
          className="px-3 py-1 bg-red-500 text-white rounded text-sm hover:bg-red-600 flex items-center gap-1"
        >
          <ExternalLink size={14} />
          Directions
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
  const [emergencies, setEmergencies] = useState([]);
  const [loading, setLoading] = useState(true);
  const [filter, setFilter] = useState('All Status');
  const [search, setSearch] = useState('');
  const [selectedUser, setSelectedUser] = useState(null);
  const [currentPage, setCurrentPage] = useState('dashboard');
  const [error, setError] = useState('');

  useEffect(() => {
    fetchEmergencies();
  }, []);

  const fetchEmergencies = async (statusFilter = null) => {
    setLoading(true);
    setError('');
    try {
      const token = getAccessToken();

      const headers = {
        'Content-Type': 'application/json',
      };
      if (token && !token.startsWith('demo_token_')) {
        headers['Authorization'] = `Bearer ${token}`;
      }

      const response = await fetch(`${API_BASE_URL}/request/emergency`, {
        method: 'GET',
        headers: headers,
      });

      if (response.ok) {
        const data = await response.json();
        let emergencyData = data.request || data || [];

        if (!Array.isArray(emergencyData)) emergencyData = [];

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
    const userData = {
      name: "Test",
      surname: "User",
      phone: "+998901234567",
      email: "kamoliddinsharopov1@gmail.com",
      age: 25,
      gender: "Male",
      passport: "AD1234567",
      blood_type: "A+",
      allergies: "none",
      illness: "none",
      additional_info: "none"
    };
    setSelectedUser(userData);
  };

  const filteredEmergencies = emergencies.filter((emergency) => {
    const matchesFilter =
      filter === 'All Status' ||
      emergency.status === filter.toLowerCase().replace(' ', '_') ||
      (filter === 'Resolved' && (emergency.status === 'resolved' || emergency.status === 'done'));

    const matchesSearch =
      search === '' ||
      emergency.type.toLowerCase().includes(search.toLowerCase()) ||
      emergency.id.toString().includes(search) ||
      (emergency.location_info || '').toLowerCase().includes(search.toLowerCase()) ||
      (emergency.assigned_to || '').toLowerCase().includes(search.toLowerCase());

    return matchesFilter && matchesSearch;
  });

  const resolvedEmergencies = emergencies.filter(
    (emergency) =>
      emergency.status === 'resolved' || emergency.status === 'done'
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
                ← Back to Dashboard
              </button>
              <h1 className="text-xl font-bold">Resolved Emergency History</h1>
            </div>
          </div>
        </header>

        <div className="p-6">
          <div className="bg-white rounded-lg shadow">
            <div className="p-4 border-b">
              <div className="grid grid-cols-6 gap-4 font-medium text-gray-700">
                <div>ID</div>
                <div>Type</div>
                <div>Contact</div>
                <div>Status</div>
                <div>Date</div>
                <div>Assigned To</div>
              </div>
            </div>

            <div className="p-4 divide-y">
              {resolvedEmergencies.length === 0 ? (
                <div className="text-center text-gray-500 py-6">No resolved emergencies in history</div>
              ) : (
                resolvedEmergencies.map((emergency) => (
                  <div
                    key={emergency.id}
                    className="grid grid-cols-6 gap-4 py-3 text-sm text-gray-800"
                  >
                    <div>{emergency.id}</div>
                    <div>{emergency.type}</div>
                    <div>{emergency.contact || 'N/A'}</div>
                    <div className="capitalize">{emergency.status}</div>
                    <div>{new Date(emergency.date_created).toLocaleString()}</div>
                    <div>{emergency.assigned_to || 'Unassigned'}</div>
                  </div>
                ))
              )}
            </div>
          </div>
        </div>
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
            <span className="text-xl font-bold">Emergency Dispatch Panel</span>
          </div>
          <div className="flex items-center gap-4">
            <span className="text-gray-600">Welcome, {user?.username}</span>
            <button
              onClick={() => setCurrentPage('history')}
              className="text-blue-600 hover:text-blue-800"
            >
              History
            </button>
            <button
              onClick={onLogout}
              className="text-red-600 hover:text-red-800"
            >
              Logout
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
              <option>All Status</option>
              <option>Pending</option>
              <option>In Progress</option>
              <option>Resolved</option>
            </select>
          </div>

          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400" size={20} />
            <input
              type="text"
              placeholder="Search by name, type, ID, or assigned staff..."
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
          <div className="text-center py-8">Loading emergencies...</div>
        ) : filteredEmergencies.length === 0 ? (
          <div className="text-center py-8 text-gray-500">
            No emergencies found
          </div>
        ) : (
          <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
            {filteredEmergencies.map((emergency) => (
              <EmergencyCard
                key={emergency.id}
                emergency={emergency}
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
        <div className="text-center">Loading...</div>
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