class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es obligatorio';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingrese un correo electrónico válido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El número de teléfono es obligatorio';
    }
    final phoneRegex = RegExp(r'^\+?51?\s?9\d{8}$|^9\d{8}$');
    if (!phoneRegex.hasMatch(value.trim().replaceAll(' ', ''))) {
      return 'Ingrese un número celular válido (+51 9XXXXXXXX)';
    }
    return null;
  }

  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre completo es obligatorio';
    }
    if (value.trim().split(' ').length < 2) {
      return 'Ingrese nombre y apellido completo';
    }
    return null;
  }

  static String? validateDni(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El DNI es obligatorio';
    }
    if (value.trim().length != 8 || int.tryParse(value.trim()) == null) {
      return 'El DNI debe tener 8 dígitos numéricos';
    }
    return null;
  }

  static String? validateRuc(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El RUC es obligatorio';
    }
    if (value.trim().length != 11 || int.tryParse(value.trim()) == null) {
      return 'El RUC debe tener 11 dígitos numéricos';
    }
    return null;
  }

  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  static String? validateStock(String? value) {
    if (value == null || value.isEmpty) {
      return 'El stock es obligatorio';
    }
    final number = int.tryParse(value);
    if (number == null || number < 0) {
      return 'Ingrese un número entero mayor o igual a 0';
    }
    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.isEmpty) {
      return 'El precio es obligatorio';
    }
    final number = double.tryParse(value);
    if (number == null || number <= 0) {
      return 'Ingrese un precio mayor a 0';
    }
    return null;
  }
}
