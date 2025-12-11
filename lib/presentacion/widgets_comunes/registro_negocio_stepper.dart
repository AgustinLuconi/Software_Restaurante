import 'package:flutter/material.dart';
import '../pantalla_inicio/pantalla_inicio_cubit.dart';

/// Widget de registro de negocio usando Stepper
/// Paso 1: Cuenta (Email y Contraseña)
/// Paso 2: Negocio (Nombre, Teléfono, Dirección)
class RegistroNegocioStepper extends StatefulWidget {
  final PantallaInicioCubit cubit;
  
  const RegistroNegocioStepper({
    super.key,
    required this.cubit,
  });

  @override
  State<RegistroNegocioStepper> createState() => _RegistroNegocioStepperState();
}

class _RegistroNegocioStepperState extends State<RegistroNegocioStepper> {
  int _currentStep = 0;
  
  // Form keys para cada paso
  final _formKeyPaso1 = GlobalKey<FormState>();
  final _formKeyPaso2 = GlobalKey<FormState>();
  
  // Controllers Paso 1 - Cuenta
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  // Controllers Paso 2 - Negocio
  final _nombreNegocioController = TextEditingController();
  final _nombreResponsableController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nombreNegocioController.dispose();
    _nombreResponsableController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_business, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Registrar Negocio',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Stepper
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: theme.colorScheme.copyWith(
                    primary: const Color(0xFF27AE60),
                  ),
                ),
                child: Stepper(
                  type: StepperType.vertical,
                  currentStep: _currentStep,
                  onStepContinue: _onStepContinue,
                  onStepCancel: _onStepCancel,
                  controlsBuilder: _buildControls,
                  steps: [
                    // Paso 1: Cuenta
                    Step(
                      title: const Text('Cuenta'),
                      subtitle: const Text('Email y contraseña'),
                      isActive: _currentStep >= 0,
                      state: _currentStep > 0 
                          ? StepState.complete 
                          : StepState.indexed,
                      content: _buildPaso1Cuenta(),
                    ),
                    
                    // Paso 2: Negocio
                    Step(
                      title: const Text('Negocio'),
                      subtitle: const Text('Información del negocio'),
                      isActive: _currentStep >= 1,
                      state: _currentStep > 1 
                          ? StepState.complete 
                          : StepState.indexed,
                      content: _buildPaso2Negocio(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Paso 1: Campos de Cuenta (Email y Contraseña)
  Widget _buildPaso1Cuenta() {
    return Form(
      key: _formKeyPaso1,
      child: Column(
        children: [
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Correo Electrónico *',
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
              hintText: 'ejemplo@correo.com',
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El correo es obligatorio';
              }
              if (!value.contains('@') || !value.contains('.')) {
                return 'Ingrese un correo válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Contraseña *',
              prefixIcon: const Icon(Icons.lock),
              border: const OutlineInputBorder(),
              hintText: 'Mínimo 6 caracteres',
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La contraseña es obligatoria';
              }
              if (value.length < 6) {
                return 'Mínimo 6 caracteres';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _confirmPasswordController,
            decoration: InputDecoration(
              labelText: 'Confirmar Contraseña *',
              prefixIcon: const Icon(Icons.lock_outline),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirme su contraseña';
              }
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Paso 2: Campos del Negocio
  Widget _buildPaso2Negocio() {
    return Form(
      key: _formKeyPaso2,
      child: Column(
        children: [
          TextFormField(
            controller: _nombreNegocioController,
            decoration: const InputDecoration(
              labelText: 'Nombre del Negocio *',
              prefixIcon: Icon(Icons.store),
              border: OutlineInputBorder(),
              hintText: 'Ej: Mi Restaurante',
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El nombre del negocio es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _nombreResponsableController,
            decoration: const InputDecoration(
              labelText: 'Nombre del Responsable *',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
              hintText: 'Ej: Juan Pérez',
            ),
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El nombre del responsable es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _telefonoController,
            decoration: const InputDecoration(
              labelText: 'Teléfono *',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
              hintText: 'Ej: +54 261 123-4567',
            ),
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El teléfono es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          
          TextFormField(
            controller: _direccionController,
            decoration: const InputDecoration(
              labelText: 'Dirección *',
              prefixIcon: Icon(Icons.location_on),
              border: OutlineInputBorder(),
              hintText: 'Ej: Av. San Martín 123',
            ),
            textInputAction: TextInputAction.done,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La dirección es obligatoria';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Construye los botones de control del Stepper
  Widget _buildControls(BuildContext context, ControlsDetails details) {
    final isLastStep = _currentStep == 1;
    
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          // Botón Continuar / Registrar
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : details.onStepContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27AE60),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: _isLoading 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(isLastStep ? Icons.check : Icons.arrow_forward),
              label: Text(
                _isLoading 
                    ? 'Registrando...' 
                    : (isLastStep ? 'Registrar' : 'Continuar'),
              ),
            ),
          ),
          
          // Botón Atrás (solo si no es el primer paso)
          if (_currentStep > 0) ...[
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : details.onStepCancel,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Atrás'),
            ),
          ],
        ],
      ),
    );
  }

  /// Validar y avanzar al siguiente paso
  void _onStepContinue() {
    if (_currentStep == 0) {
      // Validar Paso 1 - Cuenta
      if (_formKeyPaso1.currentState!.validate()) {
        setState(() {
          _currentStep = 1;
        });
      }
    } else if (_currentStep == 1) {
      // Validar Paso 2 - Negocio y registrar
      if (_formKeyPaso2.currentState!.validate()) {
        _registrarNegocio();
      }
    }
  }

  /// Retroceder al paso anterior
  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  /// Registrar el negocio
  Future<void> _registrarNegocio() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final nuevoNegocio = await widget.cubit.registrarNegocio(
        nombre: _nombreNegocioController.text.trim(),
        nombreResponsable: _nombreResponsableController.text.trim(),
        email: _emailController.text.trim(),
        telefono: _telefonoController.text.trim(),
        direccion: _direccionController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.pop(context);

      if (nuevoNegocio != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('¡${nuevoNegocio.nombre} registrado exitosamente!'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF27AE60),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('El email ya está registrado'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFE74C3C),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: const Color(0xFFE74C3C),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

/// Función helper para mostrar el diálogo de registro
void mostrarRegistroNegocioStepper(BuildContext context, PantallaInicioCubit cubit) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => RegistroNegocioStepper(cubit: cubit),
  );
}
