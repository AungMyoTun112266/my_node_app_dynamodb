import { IsEmail, IsInt, IsOptional, IsString,Length, Min } from 'class-validator';

export class CreateUserDto {
  @IsString()
  @Length(3, 50, { message: 'name must be between 3 and 50 characters long' })
  name: string='';

  @IsEmail()
  email?: string; // Marking email as optional

  @IsOptional()
  @IsInt()
  @Min(1)
  age?: number;
}

export class UpdateUserDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsEmail()
  email?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  age?: number;
}
