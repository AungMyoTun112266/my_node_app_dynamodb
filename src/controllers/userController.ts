import { Request, Response } from 'express';
import * as userService from '../services/userService';
import { User } from '../models/userModel';

export const createUser = async (req: Request, res: Response) => {
  try {
    const user: User = req.body;
    await userService.createUser(user);
    res.status(201).json({ message: 'User created successfully' });
  } catch (error) {
    res.status(500).json({ error: (error as Error).message  });
  }
};

export const getUserById = async (req: Request, res: Response) => {
  try {
    const user = await userService.getUserById(req.params.id);
    if (user) {
      res.status(200).json(user);
    } else {
      res.status(404).json({ message: 'User not found' });
    }
  } catch (error) {
    res.status(500).json({ error: (error as Error).message  });
  }
};

export const updateUser = async (req: Request, res: Response) => {
  try {
    await userService.updateUser(req.params.id, req.body);
    res.status(200).json({ message: 'User updated successfully' });
  } catch (error) {
    res.status(500).json({ error: (error as Error).message  });
  }
};

export const deleteUser = async (req: Request, res: Response) => {
  try {
    await userService.deleteUser(req.params.id);
    res.status(200).json({ message: 'User deleted successfully' });
  } catch (error) {
    res.status(500).json({ error: (error as Error).message  });
  }
};

export const getAllUsers = async (_req: Request, res: Response): Promise<Response> => {
  try {
    const users = await userService.getAllUsers();
    return res.status(200).json(users);
  } catch (error) {
    return res.status(500).json({ message: (error as Error).message });
  }
};
