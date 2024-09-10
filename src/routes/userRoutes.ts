import { Router } from 'express';
import { validateDto } from '../middlewares/validationMiddleware';
import { CreateUserDto } from '../dto/user.dto';
import * as userController from '../controllers/userController';

const router = Router();


router.post('/users', validateDto(CreateUserDto), userController.createUser);
router.post('/users', userController.createUser);
router.get('/users', userController.getAllUsers);
router.get('/users/:id', userController.getUserById);
router.put('/users/:id', userController.updateUser);
router.delete('/users/:id', userController.deleteUser);

export default router;
