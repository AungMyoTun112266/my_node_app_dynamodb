import * as userRepository from '../repositories/userRepository';
import { User } from '../models/userModel';

export const createUser = async (user: User) => {
  await userRepository.createUser(user);
};

export const getUserById = async (id: string) => {
  return await userRepository.getUserById(id);
};

export const updateUser = async (id: string, userData: Partial<User>) => {
  const updateExpression = 'set #name = :name, #email = :email';
  const expressionAttributeValues = {
    ':name': userData.name,
    ':email': userData.email,
  };
  await userRepository.updateUser(id, updateExpression, expressionAttributeValues);
};

export const deleteUser = async (id: string) => {
  await userRepository.deleteUser(id);
};

export const getAllUsers = async (): Promise<User[] | null> => {
  const { users, lastEvaluatedKey: newLastEvaluatedKey }=await userRepository.getAllUsers(5)
  return users
};
