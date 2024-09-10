import { Request, Response, NextFunction } from 'express';
import { plainToClass } from 'class-transformer';
import { validate } from 'class-validator';

export const validateDto = (dtoClass: any) => async (req: Request, res: Response, next: NextFunction) => {
  const dtoInstance = plainToClass(dtoClass, req.body);
  const errors = await validate(dtoInstance);

  if (errors.length > 0) {
    const formattedErrors = errors.reduce((acc, err) => {
      acc[err.property] = Object.values(err.constraints || {}).join(', ');
      return acc;
    }, {} as Record<string, string>);

    return res.status(400).json({ errors: formattedErrors });
  }
  next();
};
