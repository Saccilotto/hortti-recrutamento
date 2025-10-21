import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JwtService } from '@nestjs/jwt';
import { User } from '../entities/user.entity';
import { LoginDto, RegisterDto } from '../dto';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
    private readonly jwtService: JwtService,
  ) {}

  /**
   * Registra um novo usuário
   */
  async register(registerDto: RegisterDto): Promise<{ user: User; token: string }> {
    const { email, password, name, role } = registerDto;

    // Verificar se o usuário já existe
    const existingUser = await this.userRepository.findOne({ where: { email } });
    if (existingUser) {
      throw new ConflictException('Email já cadastrado');
    }

    // Criar novo usuário
    const user = this.userRepository.create({
      email,
      password, // Será hasheada automaticamente pelo BeforeInsert
      name,
      role: role || 'user',
    });

    await this.userRepository.save(user);

    // Gerar token
    const token = this.generateToken(user);

    return { user, token };
  }

  /**
   * Valida as credenciais do usuário
   */
  async validateUser(email: string, password: string): Promise<User | null> {
    const user = await this.userRepository.findOne({ where: { email } });

    if (!user || !user.isActive) {
      return null;
    }

    const isPasswordValid = await user.validatePassword(password);
    if (!isPasswordValid) {
      return null;
    }

    return user;
  }

  /**
   * Login do usuário
   */
  async login(loginDto: LoginDto): Promise<{ user: User; token: string }> {
    const { email, password } = loginDto;

    const user = await this.validateUser(email, password);
    if (!user) {
      throw new UnauthorizedException('Credenciais inválidas');
    }

    const token = this.generateToken(user);

    return { user, token };
  }

  /**
   * Busca usuário por ID
   */
  async findById(id: number): Promise<User> {
    const user = await this.userRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException('Usuário não encontrado');
    }
    return user;
  }

  /**
   * Busca usuário por email
   */
  async findByEmail(email: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { email } });
  }

  /**
   * Gera token JWT
   */
  private generateToken(user: User): string {
    const payload = {
      sub: user.id,
      email: user.email,
      role: user.role,
    };

    return this.jwtService.sign(payload);
  }

  /**
   * Verifica se o token é válido
   */
  async verifyToken(token: string): Promise<any> {
    try {
      return this.jwtService.verify(token);
    } catch (error) {
      throw new UnauthorizedException('Token inválido ou expirado');
    }
  }
}
