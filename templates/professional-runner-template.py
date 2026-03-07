# Professional Runner Template

"""
Professional Project Runner Template
Based on Project 06 Professional Transformation Standard
Eliminates "how do I run this?" questions through zero-setup execution
"""

from pathlib import Path
from dataclasses import dataclass
from datetime import datetime
from typing import List, Optional, Dict, Any
import sys
import os
import json
import subprocess

@dataclass
class ValidationResult:
    """Result of environment or input validation"""
    success: bool
    message: str
    details: Optional[Dict[str, Any]] = None

@dataclass
class ExecutionResult:
    """Result of project execution"""
    success: bool
    exit_code: int
    stdout: str
    stderr: str
    execution_time: float
    artifacts_generated: List[Path]

class ProfessionalRunner:
    """
    Professional project runner following EVA standards
    Replace {PROJECT_NAME} and {PROJECT_SPECIFIC_LOGIC} with actual values
    """
    
    def __init__(self, project_name: str = "{PROJECT_NAME}"):
        self.project_name = project_name
        self.project_root = self.auto_detect_project_root()
        self.execution_timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Standard EVA project structure
        self.directories = {
            'scripts': self.project_root / 'scripts',
            'debug': self.project_root / 'debug',
            'evidence': self.project_root / 'evidence', 
            'logs': self.project_root / 'logs',
            'input': self.project_root / 'input',
            'output': self.project_root / 'output',
            'sessions': self.project_root / 'sessions'
        }
        
        self.ensure_directories_exist()
    
    def auto_detect_project_root(self) -> Path:
        """Find project root from any subdirectory"""
        current = Path.cwd()
        
        # Look for project indicators
        indicators = [
            'README.md',
            'requirements.txt',
            'pyproject.toml',
            '.git',
            'scripts/',
            f'run_{self.project_name.lower()}.bat'
        ]
        
        # Check current directory and parents
        for path in [current] + list(current.parents):
            if any((path / indicator).exists() for indicator in indicators):
                return path
                
        # Fallback to current directory
        return current
    
    def ensure_directories_exist(self):
        """Create standard EVA project directories if they don't exist"""
        for directory in self.directories.values():
            directory.mkdir(parents=True, exist_ok=True)
    
    def validate_environment_pre_flight(self) -> ValidationResult:
        """Comprehensive pre-flight environment validation"""
        print("[INFO] Validating environment...")
        
        # Check Python version
        if sys.version_info < (3, 8):
            return ValidationResult(
                success=False,
                message="Python 3.8+ required",
                details={"current_version": sys.version}
            )
        
        # Check required files exist
        required_files = [
            self.project_root / 'requirements.txt',
            # Add project-specific required files
            # {PROJECT_SPECIFIC_FILES}
        ]
        
        missing_files = [f for f in required_files if not f.exists()]
        if missing_files:
            return ValidationResult(
                success=False,
                message="Required files missing",
                details={"missing_files": [str(f) for f in missing_files]}
            )
        
        # Check dependencies
        dependency_check = self.validate_dependencies()
        if not dependency_check.success:
            return dependency_check
            
        # {PROJECT_SPECIFIC_VALIDATION_LOGIC}
        
        return ValidationResult(success=True, message="Environment validation passed")
    
    def validate_dependencies(self) -> ValidationResult:
        """Validate required dependencies with alternative suggestions"""
        print("[INFO] Checking dependencies...")
        
        requirements_file = self.project_root / 'requirements.txt'
        if not requirements_file.exists():
            return ValidationResult(success=True, message="No requirements.txt found")
        
        missing_packages = []
        alternative_suggestions = []
        
        # Read requirements
        requirements = requirements_file.read_text().strip().split('\n')
        requirements = [r.strip() for r in requirements if r.strip() and not r.startswith('#')]
        
        for requirement in requirements:
            package_name = requirement.split('>=')[0].split('==')[0].split('~=')[0]
            try:
                __import__(package_name.replace('-', '_'))
            except ImportError:
                missing_packages.append(requirement)
                
                # Provide alternatives for known problematic packages
                if package_name == 'playwright':
                    alternative_suggestions.append(
                        "For playwright: Use DevBox environment or manual wheel installation"
                    )
        
        if missing_packages:
            return ValidationResult(
                success=False,
                message="Missing dependencies detected",
                details={
                    "missing_packages": missing_packages,
                    "alternatives": alternative_suggestions,
                    "solutions": [
                        "Run: pip install -r requirements.txt",
                        "Use DevBox environment for full access",
                        "See README.md for enterprise installation alternatives"
                    ]
                }
            )
        
        return ValidationResult(success=True, message="All dependencies available")
    
    def validate_input_files(self, **kwargs) -> ValidationResult:
        """Validate input files and parameters"""
        print("[INFO] Validating input files...")
        
        # {PROJECT_SPECIFIC_INPUT_VALIDATION}
        # Example:
        # if 'input_file' in kwargs:
        #     input_file = Path(kwargs['input_file'])
        #     if not input_file.exists():
        #         return ValidationResult(
        #             success=False,
        #             message=f"Input file not found: {input_file}"
        #         )
        
        return ValidationResult(success=True, message="Input validation passed")
    
    def build_normalized_command(self, **kwargs) -> List[str]:
        """Build normalized command from user parameters"""
        # Windows encoding safety
        if sys.platform.startswith('win'):
            os.environ['PYTHONIOENCODING'] = 'utf-8'
        
        # Base command
        main_script = self.directories['scripts'] / 'main_automation.py'
        if not main_script.exists():
            main_script = self.project_root / f'{self.project_name.lower()}_main.py'
        
        command = [sys.executable, str(main_script)]
        
        # Add standardized parameters
        command.extend(['--timestamp', self.execution_timestamp])
        command.extend(['--project-root', str(self.project_root)])
        
        # {PROJECT_SPECIFIC_PARAMETER_HANDLING}
        # Convert kwargs to command line arguments
        for key, value in kwargs.items():
            if value is not None:
                command.extend([f'--{key.replace("_", "-")}', str(value)])
        
        return command
    
    def execute_with_enterprise_safety(self, command: List[str]) -> ExecutionResult:
        """Execute command with professional error handling and evidence collection"""
        start_time = datetime.now()
        
        # Log execution start
        log_file = self.directories['logs'] / f'{self.project_name}_execution_{self.execution_timestamp}.log'
        
        print(f"[INFO] Starting {self.project_name} execution...")
        print(f"[INFO] Command: {' '.join(command)}")
        print(f"[INFO] Log file: {log_file}")
        
        try:
            # Execute with proper environment
            result = subprocess.run(
                command,
                capture_output=True,
                text=True,
                env=os.environ.copy(),
                cwd=self.project_root
            )
            
            execution_time = (datetime.now() - start_time).total_seconds()
            
            # Write execution log
            log_content = {
                "timestamp": start_time.isoformat(),
                "command": command,
                "exit_code": result.returncode,
                "execution_time": execution_time,
                "stdout": result.stdout,
                "stderr": result.stderr
            }
            
            with open(log_file, 'w', encoding='utf-8') as f:
                json.dump(log_content, f, indent=2)
            
            # Collect artifacts generated
            artifacts = self.collect_generated_artifacts()
            
            if result.returncode == 0:
                print(f"[PASS] {self.project_name} completed successfully")
                print(f"[INFO] Execution time: {execution_time:.2f} seconds")
                print(f"[INFO] Artifacts generated: {len(artifacts)}")
            else:
                print(f"[FAIL] {self.project_name} failed with exit code {result.returncode}")
                print(f"[ERROR] Check log file for details: {log_file}")
            
            return ExecutionResult(
                success=result.returncode == 0,
                exit_code=result.returncode,
                stdout=result.stdout,
                stderr=result.stderr,
                execution_time=execution_time,
                artifacts_generated=artifacts
            )
            
        except Exception as e:
            execution_time = (datetime.now() - start_time).total_seconds()
            error_message = str(e)
            
            print(f"[ERROR] {self.project_name} execution failed: {error_message}")
            
            # Log exception
            with open(log_file, 'w', encoding='utf-8') as f:
                json.dump({
                    "timestamp": start_time.isoformat(),
                    "command": command,
                    "exception": error_message,
                    "execution_time": execution_time
                }, f, indent=2)
            
            return ExecutionResult(
                success=False,
                exit_code=-1,
                stdout="",
                stderr=error_message,
                execution_time=execution_time,
                artifacts_generated=[]
            )
    
    def collect_generated_artifacts(self) -> List[Path]:
        """Collect all artifacts generated during execution"""
        artifacts = []
        
        # Check all EVA standard directories for new files
        for directory in self.directories.values():
            if directory.exists():
                for file_path in directory.iterdir():
                    if file_path.is_file() and self.execution_timestamp in file_path.name:
                        artifacts.append(file_path)
        
        return artifacts
    
    def run(self, **kwargs) -> ExecutionResult:
        """Main execution entry point - Zero-setup professional execution"""
        print(f"[INFO] {self.project_name} Professional Runner")
        print(f"[INFO] Project root: {self.project_root}")
        print(f"[INFO] Execution timestamp: {self.execution_timestamp}")
        
        # 1. Pre-flight environment validation
        env_validation = self.validate_environment_pre_flight()
        if not env_validation.success:
            print(f"[FAIL] Environment validation failed: {env_validation.message}")
            if env_validation.details:
                for key, value in env_validation.details.items():
                    print(f"[ERROR] {key}: {value}")
            return ExecutionResult(
                success=False, exit_code=-1, stdout="", stderr=env_validation.message,
                execution_time=0.0, artifacts_generated=[]
            )
        
        # 2. Input validation
        input_validation = self.validate_input_files(**kwargs)
        if not input_validation.success:
            print(f"[FAIL] Input validation failed: {input_validation.message}")
            return ExecutionResult(
                success=False, exit_code=-1, stdout="", stderr=input_validation.message,
                execution_time=0.0, artifacts_generated=[]
            )
        
        # 3. Build normalized command
        command = self.build_normalized_command(**kwargs)
        
        # 4. Execute with professional error handling
        return self.execute_with_enterprise_safety(command)


def main():
    """Command line interface for professional runner"""
    import argparse
    
    parser = argparse.ArgumentParser(description=f'{PROJECT_NAME} Professional Runner')
    # {PROJECT_SPECIFIC_CLI_ARGUMENTS}
    
    args = parser.parse_args()
    
    # Convert args to kwargs
    kwargs = {key: value for key, value in vars(args).items() if value is not None}
    
    # Execute
    runner = ProfessionalRunner()
    result = runner.run(**kwargs)
    
    # Exit with proper code
    sys.exit(result.exit_code)


if __name__ == '__main__':
    main()